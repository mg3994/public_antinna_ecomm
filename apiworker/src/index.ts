import { Hono } from 'hono';
import { cors } from 'hono/cors';

export interface Env {
  DB: D1Database;
  SESSIONS: KVNamespace;
  FIREBASE_PROJECT_ID: string;
}

const app = new Hono<{ Bindings: Env }>();

// Enable CORS for custom domain and Blogger subdomain compatibility
app.use('*', cors({
  origin: '*',
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowHeaders: ['Content-Type', 'Authorization', 'X-Antinna-Client-Id'],
  maxAge: 86400,
}));

// Utility to decode JWT claims from Firebase ID Token without external dependencies
function decodeJwt(token: string): any {
  try {
    const parts = token.split('.');
    if (parts.length !== 3) return null;
    const payload = parts[1];

    // Base64URL decode compliant with Cloudflare Workers environment
    const base64 = payload.replace(/-/g, '+').replace(/_/g, '/');
    const jsonPayload = decodeURIComponent(
      atob(base64)
        .split('')
        .map((c) => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2))
        .join('')
    );
    return JSON.parse(jsonPayload);
  } catch (e) {
    console.error('Failed to decode JWT payload:', e);
    return null;
  }
}

// Convert Base64URL token signature to Uint8Array for Web Crypto verification
function base64UrlToUint8Array(str: string): Uint8Array {
  const base64 = str.replace(/-/g, '+').replace(/_/g, '/');
  const pad = base64.length % 4;
  const padded = pad ? base64 + '='.repeat(4 - pad) : base64;
  const binary = atob(padded);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes;
}

// Enterprise-grade Firebase ID Token cryptographic RS256 claims verification
async function verifyFirebaseIdToken(token: string, projectId: string, kv: KVNamespace): Promise<any | null> {
  const parts = token.split('.');
  if (parts.length !== 3) return null;

  const header = decodeJwt(parts[0]);
  const decoded = decodeJwt(parts[1]);
  if (!header || !decoded) return null;

  const now = Math.floor(Date.now() / 1000);

  // 1. Verify token is not expired
  if (decoded.exp && now >= decoded.exp) {
    console.error('ID Token expired. exp:', decoded.exp, 'now:', now);
    return null;
  }

  // 2. Verify audience matches the target Firebase Project ID
  if (decoded.aud !== projectId) {
    console.error('ID Token audience mismatch. aud:', decoded.aud, 'expected:', projectId);
    return null;
  }

  // 3. Verify issuer matches the expected secure token URL
  const expectedIssuer = `https://securetoken.google.com/${projectId}`;
  if (decoded.iss !== expectedIssuer) {
    console.error('ID Token issuer mismatch. iss:', decoded.iss, 'expected:', expectedIssuer);
    return null;
  }

  // 4. Verify Cryptographic RS256 Signature using Google JWK cached in KV
  try {
    const kid = header.kid;
    if (!kid) {
      console.error('Missing kid claim in JWT header.');
      return null;
    }

    // Cache Google JWK certificates in SESSIONS KV Namespace to reduce network requests
    const cacheKey = 'firebase_public_jwks';
    let jwksStr = await kv.get(cacheKey);
    let jwks: any;

    if (jwksStr) {
      jwks = JSON.parse(jwksStr);
    } else {
      const jwksUrl = 'https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com';
      const res = await fetch(jwksUrl);
      if (!res.ok) throw new Error('Failed to fetch Google JWKs.');
      jwks = await res.json();

      // Cache Google JWKs for 1 hour (3600 seconds) in KV Namespace
      await kv.put(cacheKey, JSON.stringify(jwks), { expirationTtl: 3600 });
    }

    const keysList = jwks.keys || [];
    const targetJwk = keysList.find((key: any) => key.kid === kid);
    if (!targetJwk) {
      console.error('No matching JWK found for kid:', kid);
      return null;
    }

    // Import JWK natively into browser Web Crypto object
    const cryptoKey = await crypto.subtle.importKey(
      'jwk',
      targetJwk,
      { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
      false,
      ['verify']
    );

    // Verify RSASSA-PKCS1-v1_5 signature against signed JWT content
    const dataBytes = new TextEncoder().encode(`${parts[0]}.${parts[1]}`);
    const signatureBytes = base64UrlToUint8Array(parts[2]);

    const verified = await crypto.subtle.verify(
      'RSASSA-PKCS1-v1_5',
      cryptoKey,
      signatureBytes,
      dataBytes
    );

    if (!verified) {
      console.error('RS256 signature verification failed!');
      return null;
    }

    return {
      uid: decoded.sub,
      email: decoded.email,
      name: decoded.name,
      picture: decoded.picture,
      phoneNumber: decoded.phone_number
    };
  } catch (err) {
    console.error('Cryptographic signature verification threw exception:', err);
    return null;
  }
}

// Auto-bootstrap tables inside Cloudflare D1 Database if they do not exist
async function bootstrapDatabase(db: D1Database) {
  await db.batch([
    db.prepare(`
      CREATE TABLE IF NOT EXISTS orders (
        id TEXT PRIMARY KEY,
        payload TEXT NOT NULL,
        status TEXT DEFAULT 'PENDING',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `),
    db.prepare(`
      CREATE TABLE IF NOT EXISTS payments (
        id TEXT PRIMARY KEY,
        order_id TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(order_id) REFERENCES orders(id)
      )
    `)
  ]);
}

// Helper to extract Bearer token from header
function getBearerToken(authHeader: string | undefined): string | null {
  if (authHeader && authHeader.startsWith('Bearer ')) {
    return authHeader.substring(7);
  }
  return null;
}

// 1. POST /orders: Create a new order record
app.post('/orders', async (c) => {
  const db = c.env.DB;
  const kv = c.env.SESSIONS;
  const projectId = c.env.FIREBASE_PROJECT_ID || 'antinnamain';

  if (!db) {
    return c.json({ error: 'Database binding "DB" is missing.' }, 500);
  }
  if (!kv) {
    return c.json({ error: 'KV Namespace binding "SESSIONS" is missing.' }, 500);
  }

  try {
    await bootstrapDatabase(db);
    const order = await c.req.json();
    const orderId = order.id || `ord_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;

    // Parse and verify Authorization header for claims enrichment
    const token = getBearerToken(c.req.header('Authorization'));
    let userDetails: any = null;

    if (token) {
      userDetails = await verifyFirebaseIdToken(token, projectId, kv);
    }

    // Rich Schema-LD enrichment: map userDetails as Person onto the order customer field
    if (userDetails) {
      order.customer = {
        "@type": "Person",
        "identifier": userDetails.uid,
        "name": userDetails.name || undefined,
        "email": userDetails.email || undefined,
        "telephone": userDetails.phoneNumber || undefined,
        "image": userDetails.picture || undefined
      };
    }

    // Store full stringified JSON-LD payload of order
    await db.prepare('INSERT OR REPLACE INTO orders (id, payload) VALUES (?, ?)')
      .bind(orderId, JSON.stringify(order))
      .run();

    return c.json({ success: true, orderId, order, message: 'Order created and customer claims linked successfully.' }, 201);
  } catch (err: any) {
    return c.json({ error: 'Failed to create order', details: err.message }, 500);
  }
});

// 2. GET /orders: List paginated orders
app.get('/orders', async (c) => {
  const db = c.env.DB;
  if (!db) {
    return c.json({ error: 'Database binding "DB" is missing.' }, 500);
  }

  const page = parseInt(c.req.query('page') || '1') || 1;
  const pageSize = parseInt(c.req.query('pageSize') || '20') || 20;
  const offset = (page - 1) * pageSize;

  try {
    await bootstrapDatabase(db);

    const { results } = await db.prepare('SELECT * FROM orders ORDER BY created_at DESC LIMIT ? OFFSET ?')
      .bind(pageSize, offset)
      .all();

    // Map payload strings back to JS objects dynamically for ease of use
    const parsedOrders = results.map((row: any) => ({
      ...row,
      payload: JSON.parse(row.payload)
    }));

    const countResult = await db.prepare('SELECT COUNT(*) as count FROM orders').first<{ count: number }>();
    const totalResults = countResult?.count ?? 0;

    return c.json({
      orders: parsedOrders,
      totalResults,
      page,
      pageSize,
    });
  } catch (err: any) {
    return c.json({ error: 'Failed to retrieve orders', details: err.message }, 500);
  }
});

// 3. GET /orders/:id/status: Check order payment status
app.get('/orders/:id/status', async (c) => {
  const db = c.env.DB;
  if (!db) {
    return c.json({ error: 'Database binding "DB" is missing.' }, 500);
  }

  const orderId = c.req.param('id');

  try {
    await bootstrapDatabase(db);
    const result = await db.prepare('SELECT status FROM orders WHERE id = ?')
      .bind(orderId)
      .first<{ status: string }>();

    if (!result) {
      return c.json({ error: 'Order not found' }, 404);
    }

    return c.json({ orderId, status: result.status });
  } catch (err: any) {
    return c.json({ error: 'Failed to retrieve order status', details: err.message }, 500);
  }
});

// 4. POST /payments: Record a payment (requires verified firebase ID Token + idempotent checkout)
app.post('/payments', async (c) => {
  const db = c.env.DB;
  const kv = c.env.SESSIONS;
  const projectId = c.env.FIREBASE_PROJECT_ID || 'antinnamain';

  if (!db) {
    return c.json({ error: 'Database binding "DB" is missing.' }, 500);
  }
  if (!kv) {
    return c.json({ error: 'KV Namespace binding "SESSIONS" is missing.' }, 500);
  }

  // Mandatory Token Verification Check
  const token = getBearerToken(c.req.header('Authorization'));
  if (!token) {
    return c.json({ error: 'Unauthorized: Missing Authorization Bearer ID Token.' }, 401);
  }

  const verifiedUser = await verifyFirebaseIdToken(token, projectId, kv);
  if (!verifiedUser) {
    return c.json({ error: 'Unauthorized: Firebase ID Token signature is invalid, expired, or project ID mismatches.' }, 401);
  }

  try {
    await bootstrapDatabase(db);
    const paymentData = await c.req.json();
    const orderId = paymentData.orderId;
    const paymentId = paymentData.id || `pay_${Date.now()}`;

    if (!orderId) {
      return c.json({ error: 'Missing required field: orderId' }, 400);
    }

    // Safety check: verify order exists
    const orderExists = await db.prepare('SELECT id, status FROM orders WHERE id = ?')
      .bind(orderId)
      .first<{ id: string; status: string }>();

    if (!orderExists) {
      return c.json({ error: 'Order ID does not exist in records' }, 400);
    }

    // Idempotency check: reject duplicate payments if already paid
    if (orderExists.status === 'PAID') {
      return c.json({ success: true, message: 'Order already recorded as PAID. Payment check bypassed.', orderId }, 200);
    }

    // Store payment transaction & update order status to PAID transactionally
    await db.batch([
      db.prepare('INSERT OR REPLACE INTO payments (id, order_id, payload) VALUES (?, ?, ?)')
        .bind(paymentId, orderId, JSON.stringify(paymentData)),
      db.prepare('UPDATE orders SET status = "PAID" WHERE id = ?')
        .bind(orderId)
    ]);

    // Store notification inside KV Namespace (Reverse chronological key suffix)
    const reverseTimeKey = (9999999999999 - Date.now()).toString();
    const notificationKey = `notification:${reverseTimeKey}`;
    const notificationObj = {
      id: reverseTimeKey,
      title: 'Payment Success',
      body: `Payment for Order ${orderId} has been successfully recorded.`,
      created_at: new Date().toISOString()
    };

    await kv.put(notificationKey, JSON.stringify(notificationObj));

    return c.json({ success: true, paymentId, message: 'Payment recorded and order status set to PAID.' }, 201);
  } catch (err: any) {
    return c.json({ error: 'Failed to record payment', details: err.message }, 500);
  }
});

// 5. GET /notifications: List paginated notifications from KV Namespace SESSIONS
app.get('/notifications', async (c) => {
  const kv = c.env.SESSIONS;
  if (!kv) {
    return c.json({ error: 'KV Namespace binding "SESSIONS" is missing.' }, 500);
  }

  const page = parseInt(c.req.query('page') || '1') || 1;
  const pageSize = parseInt(c.req.query('pageSize') || '20') || 20;
  const offset = (page - 1) * pageSize;

  try {
    // List keys starting with prefix 'notification:'
    const listResult = await kv.list({ prefix: 'notification:' });
    const keys = listResult.keys;

    // Slice based on pagination requirements
    const paginatedKeys = keys.slice(offset, offset + pageSize);
    const notificationsList: any[] = [];

    for (const key of paginatedKeys) {
      const val = await kv.get(key.name);
      if (val) {
        notificationsList.push(JSON.parse(val));
      }
    }

    return c.json({
      notifications: notificationsList,
      totalResults: keys.length,
      page,
      pageSize,
    });
  } catch (err: any) {
    return c.json({ error: 'Failed to retrieve notifications from KV', details: err.message }, 500);
  }
});

// 6. GET /notifications/:id: Read specific notification by ID from KV Namespace SESSIONS
app.get('/notifications/:id', async (c) => {
  const kv = c.env.SESSIONS;
  if (!kv) {
    return c.json({ error: 'KV Namespace binding "SESSIONS" is missing.' }, 500);
  }

  const notificationId = c.req.param('id');

  try {
    const val = await kv.get(`notification:${notificationId}`);
    if (!val) {
      return c.json({ error: 'Notification not found' }, 404);
    }

    return c.json(JSON.parse(val));
  } catch (err: any) {
    return c.json({ error: 'Failed to retrieve notification from KV', details: err.message }, 500);
  }
});

// 7. POST /sessions: Store or update user session data inside KV (using browserClientId)
app.post('/sessions', async (c) => {
  const kv = c.env.SESSIONS;
  if (!kv) {
    return c.json({ error: 'KV Namespace binding "SESSIONS" is missing.' }, 500);
  }

  try {
    const { browserClientId, sessionData } = await c.req.json();
    if (!browserClientId || !sessionData) {
      return c.json({ error: 'Missing required fields: browserClientId or sessionData' }, 400);
    }

    // Persist session to KV with optional 7 days expiration (604800 seconds)
    await kv.put(`session:${browserClientId}`, JSON.stringify(sessionData), { expirationTtl: 604800 });
    return c.json({ success: true, browserClientId, message: 'User browser session stored successfully inside KV.' });
  } catch (err: any) {
    return c.json({ error: 'Failed to store user session', details: err.message }, 500);
  }
});

// 8. GET /sessions/:browserClientId: Retrieve user session data from KV
app.get('/sessions/:browserClientId', async (c) => {
  const kv = c.env.SESSIONS;
  if (!kv) {
    return c.json({ error: 'KV Namespace binding "SESSIONS" is missing.' }, 500);
  }

  const browserClientId = c.req.param('browserClientId');

  try {
    const savedSession = await kv.get(`session:${browserClientId}`);
    if (!savedSession) {
      return c.json({ error: 'Session not found or expired' }, 404);
    }

    return c.json({ browserClientId, sessionData: JSON.parse(savedSession) });
  } catch (err: any) {
    return c.json({ error: 'Failed to retrieve session data', details: err.message }, 500);
  }
});

// 9. DELETE /sessions/:browserClientId: Delete user session data from KV
app.delete('/sessions/:browserClientId', async (c) => {
  const kv = c.env.SESSIONS;
  if (!kv) {
    return c.json({ error: 'KV Namespace binding "SESSIONS" is missing.' }, 500);
  }

  const browserClientId = c.req.param('browserClientId');

  try {
    await kv.delete(`session:${browserClientId}`);
    return c.json({ success: true, browserClientId, message: 'User session terminated and removed from KV.' });
  } catch (err: any) {
    return c.json({ error: 'Failed to terminate session', details: err.message }, 500);
  }
});

// Favicon redirect
app.get('/favicon.ico', (c) => {
  return c.redirect('https://www.antinna.in/favicon.ico', 301);
});

// Root welcome message
app.get('/', (c) => {
  return c.text('Welcome to Antinna Ecommerce API Server powered by Hono on Cloudflare Workers!');
});

export default app;

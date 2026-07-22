import { Hono } from 'hono';
import { cors } from 'hono/cors';

export interface Env {
  DB: D1Database;
  SESSIONS: KVNamespace;
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
    `),
    db.prepare(`
      CREATE TABLE IF NOT EXISTS notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `)
  ]);
}

// 1. POST /orders: Create a new order record
app.post('/orders', async (c) => {
  const db = c.env.DB;
  if (!db) {
    return c.json({ error: 'Database binding "DB" is missing.' }, 500);
  }

  try {
    await bootstrapDatabase(db);
    const order = await c.req.json();
    const orderId = order.id || `ord_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;

    // Parse Authorization header for Firebase ID token
    const authHeader = c.req.header('Authorization');
    let userDetails: any = null;

    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      const decoded = decodeJwt(token);
      if (decoded) {
        userDetails = {
          uid: decoded.sub,
          email: decoded.email,
          name: decoded.name,
          picture: decoded.picture,
          phoneNumber: decoded.phone_number
        };
      }
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

// 4. POST /payments: Record a payment (idempotent payment processor)
app.post('/payments', async (c) => {
  const db = c.env.DB;
  if (!db) {
    return c.json({ error: 'Database binding "DB" is missing.' }, 500);
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

    // Insert auto-notification on payment success
    await db.prepare('INSERT INTO notifications (title, body) VALUES (?, ?)')
      .bind('Payment Success', `Payment for Order ${orderId} has been successfully recorded.`)
      .run();

    return c.json({ success: true, paymentId, message: 'Payment recorded and order status set to PAID.' }, 201);
  } catch (err: any) {
    return c.json({ error: 'Failed to record payment', details: err.message }, 500);
  }
});

// 5. GET /notifications: List paginated notifications
app.get('/notifications', async (c) => {
  const db = c.env.DB;
  if (!db) {
    return c.json({ error: 'Database binding "DB" is missing.' }, 500);
  }

  const page = parseInt(c.req.query('page') || '1') || 1;
  const pageSize = parseInt(c.req.query('pageSize') || '20') || 20;
  const offset = (page - 1) * pageSize;

  try {
    await bootstrapDatabase(db);

    const { results } = await db.prepare('SELECT * FROM notifications ORDER BY created_at DESC LIMIT ? OFFSET ?')
      .bind(pageSize, offset)
      .all();

    const countResult = await db.prepare('SELECT COUNT(*) as count FROM notifications').first<{ count: number }>();
    const totalResults = countResult?.count ?? 0;

    return c.json({
      notifications: results,
      totalResults,
      page,
      pageSize,
    });
  } catch (err: any) {
    return c.json({ error: 'Failed to retrieve notifications', details: err.message }, 500);
  }
});

// 6. GET /notifications/:id: Read specific notification by ID
app.get('/notifications/:id', async (c) => {
  const db = c.env.DB;
  if (!db) {
    return c.json({ error: 'Database binding "DB" is missing.' }, 500);
  }

  const notificationId = c.req.param('id');

  try {
    await bootstrapDatabase(db);
    const result = await db.prepare('SELECT * FROM notifications WHERE id = ?')
      .bind(notificationId)
      .first();

    if (!result) {
      return c.json({ error: 'Notification not found' }, 404);
    }

    return c.json(result);
  } catch (err: any) {
    return c.json({ error: 'Failed to retrieve notification', details: err.message }, 500);
  }
});

// 7. POST /sessions: Store or update user session data inside KV
app.post('/sessions', async (c) => {
  const kv = c.env.SESSIONS;
  if (!kv) {
    return c.json({ error: 'KV Namespace binding "SESSIONS" is missing.' }, 500);
  }

  try {
    const { userId, sessionData } = await c.req.json();
    if (!userId || !sessionData) {
      return c.json({ error: 'Missing required fields: userId or sessionData' }, 400);
    }

    // Persist session to KV with optional 7 days expiration (604800 seconds)
    await kv.put(userId, JSON.stringify(sessionData), { expirationTtl: 604800 });
    return c.json({ success: true, userId, message: 'User session stored successfully inside KV.' });
  } catch (err: any) {
    return c.json({ error: 'Failed to store user session', details: err.message }, 500);
  }
});

// 8. GET /sessions/:userId: Retrieve user session data from KV
app.get('/sessions/:userId', async (c) => {
  const kv = c.env.SESSIONS;
  if (!kv) {
    return c.json({ error: 'KV Namespace binding "SESSIONS" is missing.' }, 500);
  }

  const userId = c.req.param('userId');

  try {
    const savedSession = await kv.get(userId);
    if (!savedSession) {
      return c.json({ error: 'Session not found or expired' }, 404);
    }

    return c.json({ userId, sessionData: JSON.parse(savedSession) });
  } catch (err: any) {
    return c.json({ error: 'Failed to retrieve session data', details: err.message }, 500);
  }
});

// 9. DELETE /sessions/:userId: Delete user session data from KV
app.delete('/sessions/:userId', async (c) => {
  const kv = c.env.SESSIONS;
  if (!kv) {
    return c.json({ error: 'KV Namespace binding "SESSIONS" is missing.' }, 500);
  }

  const userId = c.req.param('userId');

  try {
    await kv.delete(userId);
    return c.json({ success: true, userId, message: 'User session terminated and removed from KV.' });
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

import { Hono } from 'hono';
import {
  CreateOrderUseCase,
  GetOrdersUseCase,
  GetOrderStatusUseCase,
  RecordPaymentUseCase,
  GetNotificationsUseCase,
  GetNotificationByIdUseCase,
  SaveSessionUseCase,
  GetSessionUseCase,
  DeleteSessionUseCase
} from '../application/usecases';
import { IDatabaseBootstrapper } from '../domain/types';

export interface Env {
  DB: D1Database;
  SESSIONS: KVNamespace;
  FIREBASE_PROJECT_ID: string;
}

export function configureRoutes(
  app: Hono<{ Bindings: Env }>,
  bootstrapper: IDatabaseBootstrapper,
  createOrderUseCase: CreateOrderUseCase,
  getOrdersUseCase: GetOrdersUseCase,
  getOrderStatusUseCase: GetOrderStatusUseCase,
  recordPaymentUseCase: RecordPaymentUseCase,
  getNotificationsUseCase: GetNotificationsUseCase,
  getNotificationByIdUseCase: GetNotificationByIdUseCase,
  saveSessionUseCase: SaveSessionUseCase,
  getSessionUseCase: GetSessionUseCase,
  deleteSessionUseCase: DeleteSessionUseCase
): void {

  // Helper middleware/callback to check and bootstrap DB
  const ensureDb = async (c: any) => {
    const db = c.env.DB;
    if (!db) {
      throw new Error('Database binding "DB" is missing.');
    }
    await bootstrapper.bootstrap(db);
  };

  // 1. POST /orders: Create a new order record
  app.post('/orders', async (c) => {
    const db = c.env.DB;
    const kv = c.env.SESSIONS;
    const projectId = c.env.FIREBASE_PROJECT_ID || 'antinnamain';

    if (!db) return c.json({ error: 'Database binding "DB" is missing.' }, 500);
    if (!kv) return c.json({ error: 'KV Namespace binding "SESSIONS" is missing.' }, 500);

    try {
      await ensureDb(c);
      const order = await c.req.json();
      const authHeader = c.req.header('Authorization');

      const result = await createOrderUseCase.execute(db, kv, projectId, order, authHeader);
      return c.json({
        success: true,
        orderId: result.orderId,
        order: result.order,
        message: 'Order created and customer claims linked successfully.'
      }, 201);
    } catch (err: any) {
      return c.json({ error: 'Failed to create order', details: err.message }, 500);
    }
  });

  // 2. GET /orders: List paginated orders (Tenant-aware filter checking database-backed claims)
  app.get('/orders', async (c) => {
    const db = c.env.DB;
    const kv = c.env.SESSIONS;
    const projectId = c.env.FIREBASE_PROJECT_ID || 'antinnamain';

    if (!db) return c.json({ error: 'Database binding "DB" is missing.' }, 500);
    if (!kv) return c.json({ error: 'KV Namespace binding "SESSIONS" is missing.' }, 500);

    const authHeader = c.req.header('Authorization');
    const page = parseInt(c.req.query('page') || '1') || 1;
    const pageSize = parseInt(c.req.query('pageSize') || '20') || 20;

    try {
      await ensureDb(c);
      const result = await getOrdersUseCase.execute(db, kv, projectId, authHeader, page, pageSize);
      return c.json({
        orders: result.orders,
        totalResults: result.totalResults,
        page,
        pageSize,
      });
    } catch (err: any) {
      const status = err.message.startsWith('Unauthorized') ? 401 : 500;
      return c.json({ error: err.message }, status);
    }
  });

  // 3. GET /orders/:id/status: Check order payment status
  app.get('/orders/:id/status', async (c) => {
    const db = c.env.DB;
    if (!db) return c.json({ error: 'Database binding "DB" is missing.' }, 500);

    const orderId = c.req.param('id');

    try {
      await ensureDb(c);
      const status = await getOrderStatusUseCase.execute(db, orderId);
      return c.json({ orderId, status });
    } catch (err: any) {
      const status = err.message === 'Order not found' ? 404 : 500;
      return c.json({ error: err.message }, status);
    }
  });

  // 4. POST /payments: Record a payment (requires verified Owner/Moderator claims + idempotent checkout)
  app.post('/payments', async (c) => {
    const db = c.env.DB;
    const kv = c.env.SESSIONS;
    const projectId = c.env.FIREBASE_PROJECT_ID || 'antinnamain';

    if (!db) return c.json({ error: 'Database binding "DB" is missing.' }, 500);
    if (!kv) return c.json({ error: 'KV Namespace binding "SESSIONS" is missing.' }, 500);

    const authHeader = c.req.header('Authorization');

    try {
      await ensureDb(c);
      const paymentData = await c.req.json();
      const result = await recordPaymentUseCase.execute(db, kv, projectId, authHeader, paymentData);

      const statusCode: any = result.alreadyPaid ? 200 : 201;
      return c.json({
        success: true,
        paymentId: result.paymentId,
        message: result.message
      }, statusCode);
    } catch (err: any) {
      let status: any = 500;
      if (err.message.startsWith('Unauthorized')) {
        status = 401;
      } else if (err.message.startsWith('Forbidden')) {
        status = 403;
      } else if (err.message.startsWith('Missing') || err.message.includes('exist')) {
        status = 400;
      }
      return c.json({ error: err.message }, status);
    }
  });

  // 5. GET /notifications: List paginated notifications from KV Namespace SESSIONS
  app.get('/notifications', async (c) => {
    const kv = c.env.SESSIONS;
    if (!kv) return c.json({ error: 'KV Namespace binding "SESSIONS" is missing.' }, 500);

    const page = parseInt(c.req.query('page') || '1') || 1;
    const pageSize = parseInt(c.req.query('pageSize') || '20') || 20;

    try {
      const result = await getNotificationsUseCase.execute(kv, page, pageSize);
      return c.json({
        notifications: result.notifications,
        totalResults: result.totalResults,
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
    if (!kv) return c.json({ error: 'KV Namespace binding "SESSIONS" is missing.' }, 500);

    const notificationId = c.req.param('id');

    try {
      const notification = await getNotificationByIdUseCase.execute(kv, notificationId);
      return c.json(notification);
    } catch (err: any) {
      const status = err.message === 'Notification not found' ? 404 : 500;
      return c.json({ error: err.message }, status);
    }
  });

  // 7. POST /sessions: Store or update user session data inside KV (using browserClientId)
  app.post('/sessions', async (c) => {
    const kv = c.env.SESSIONS;
    if (!kv) return c.json({ error: 'KV Namespace binding "SESSIONS" is missing.' }, 500);

    try {
      const { browserClientId, sessionData } = await c.req.json();
      await saveSessionUseCase.execute(kv, browserClientId, sessionData);
      return c.json({
        success: true,
        browserClientId,
        message: 'User browser session stored successfully inside KV.'
      });
    } catch (err: any) {
      const status = err.message.startsWith('Missing') ? 400 : 500;
      return c.json({ error: err.message }, status);
    }
  });

  // 8. GET /sessions/:browserClientId: Retrieve user session data from KV
  app.get('/sessions/:browserClientId', async (c) => {
    const kv = c.env.SESSIONS;
    if (!kv) return c.json({ error: 'KV Namespace binding "SESSIONS" is missing.' }, 500);

    const browserClientId = c.req.param('browserClientId');

    try {
      const sessionData = await getSessionUseCase.execute(kv, browserClientId);
      return c.json({ browserClientId, sessionData });
    } catch (err: any) {
      const status = err.message.includes('not found') ? 404 : 500;
      return c.json({ error: err.message }, status);
    }
  });

  // 9. DELETE /sessions/:browserClientId: Delete user session data from KV
  app.delete('/sessions/:browserClientId', async (c) => {
    const kv = c.env.SESSIONS;
    if (!kv) return c.json({ error: 'KV Namespace binding "SESSIONS" is missing.' }, 500);

    const browserClientId = c.req.param('browserClientId');

    try {
      await deleteSessionUseCase.execute(kv, browserClientId);
      return c.json({
        success: true,
        browserClientId,
        message: 'User session terminated and removed from KV.'
      });
    } catch (err: any) {
      return c.json({ error: 'Failed to terminate session', details: err.message }, 500);
    }
  });
}

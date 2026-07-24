import { IOrderRepository, Order } from '../domain/types';

export class OrderRepository implements IOrderRepository {
  async saveOrder(db: any, orderId: string, order: any): Promise<void> {
    await db.prepare('INSERT OR REPLACE INTO orders (id, payload) VALUES (?, ?)')
      .bind(orderId, JSON.stringify(order))
      .run();
  }

  async getOrderById(db: any, orderId: string): Promise<Order | null> {
    const row = await db.prepare('SELECT id, status, payload, created_at FROM orders WHERE id = ?')
      .bind(orderId)
      .first() as any;

    if (!row) return null;

    return {
      id: row.id,
      status: row.status,
      payload: JSON.parse(row.payload),
      created_at: row.created_at
    };
  }

  async getAllOrders(db: any): Promise<Order[]> {
    const { results } = await db.prepare('SELECT id, status, payload, created_at FROM orders ORDER BY created_at DESC').all();
    return results.map((row: any) => ({
      id: row.id,
      status: row.status,
      payload: JSON.parse(row.payload),
      created_at: row.created_at
    }));
  }
}

import { IPaymentRepository } from '../domain/types';

export class PaymentRepository implements IPaymentRepository {
  async recordPayment(db: any, paymentId: string, orderId: string, paymentData: any): Promise<void> {
    await db.batch([
      db.prepare('INSERT OR REPLACE INTO payments (id, order_id, payload) VALUES (?, ?, ?)')
        .bind(paymentId, orderId, JSON.stringify(paymentData)),
      db.prepare('UPDATE orders SET status = "PAID" WHERE id = ?')
        .bind(orderId)
    ]);
  }
}

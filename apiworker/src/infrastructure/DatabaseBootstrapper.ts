import { IDatabaseBootstrapper } from '../domain/types';

export class DatabaseBootstrapper implements IDatabaseBootstrapper {
  async bootstrap(db: any): Promise<void> {
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
        CREATE TABLE IF NOT EXISTS user_claims (
          uid TEXT PRIMARY KEY,
          owners TEXT NOT NULL,
          moderators TEXT NOT NULL,
          staffs TEXT NOT NULL
        )
      `)
    ]);
  }
}

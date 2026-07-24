import { ISessionRepository } from '../domain/types';

export class SessionRepository implements ISessionRepository {
  async saveSession(kv: any, browserClientId: string, sessionData: any, ttlSeconds: number): Promise<void> {
    const key = `session:${browserClientId}`;
    await kv.put(key, JSON.stringify(sessionData), { expirationTtl: ttlSeconds });
  }

  async getSession(kv: any, browserClientId: string): Promise<any | null> {
    const savedSession = await kv.get(`session:${browserClientId}`);
    if (!savedSession) return null;
    return JSON.parse(savedSession);
  }

  async deleteSession(kv: any, browserClientId: string): Promise<void> {
    const key = `session:${browserClientId}`;
    await kv.delete(key);
  }
}

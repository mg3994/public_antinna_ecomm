import { INotificationRepository, Notification } from '../domain/types';

export class NotificationRepository implements INotificationRepository {
  async saveNotification(kv: any, notification: Notification): Promise<void> {
    const key = `notification:${notification.id}`;
    await kv.put(key, JSON.stringify(notification));
  }

  async getNotifications(kv: any, page: number, pageSize: number): Promise<{ notifications: Notification[]; totalResults: number }> {
    const listResult = await kv.list({ prefix: 'notification:' });
    const keys = listResult.keys;

    const offset = (page - 1) * pageSize;
    const paginatedKeys = keys.slice(offset, offset + pageSize);
    const notifications: Notification[] = [];

    for (const key of paginatedKeys) {
      const val = await kv.get(key.name);
      if (val) {
        notifications.push(JSON.parse(val));
      }
    }

    return {
      notifications,
      totalResults: keys.length
    };
  }

  async getNotificationById(kv: any, id: string): Promise<Notification | null> {
    const val = await kv.get(`notification:${id}`);
    if (!val) return null;
    return JSON.parse(val);
  }
}

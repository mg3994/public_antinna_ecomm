export interface VerifiedUser {
  uid: string;
  email?: string;
  name?: string;
  picture?: string;
  phoneNumber?: string;
}

export interface UserClaims {
  owners: string[];
  moderators: string[];
  staffs: string[];
}

export interface Order {
  id: string;
  payload: any;
  status: string;
  created_at?: string;
}

export interface Payment {
  id: string;
  orderId: string;
  payload: any;
  created_at?: string;
}

export interface Notification {
  id: string;
  title: string;
  body: string;
  created_at: string;
}

export interface Session {
  browserClientId: string;
  sessionData: any;
}

// Ports / Interfaces for repositories and services
export interface IAuthService {
  verifyIdToken(token: string, projectId: string, kv: any): Promise<VerifiedUser | null>;
  getUserClaims(db: any, uid: string): Promise<UserClaims>;
  hasStoreAccess(claims: UserClaims, storeId: string, requiredRoles: ('o' | 'm' | 's')[]): boolean;
}

export interface IDatabaseBootstrapper {
  bootstrap(db: any): Promise<void>;
}

export interface IOrderRepository {
  saveOrder(db: any, orderId: string, order: any): Promise<void>;
  getOrderById(db: any, orderId: string): Promise<Order | null>;
  getAllOrders(db: any): Promise<Order[]>;
}

export interface IPaymentRepository {
  recordPayment(db: any, paymentId: string, orderId: string, paymentData: any): Promise<void>;
}

export interface INotificationRepository {
  saveNotification(kv: any, notification: Notification): Promise<void>;
  getNotifications(kv: any, page: number, pageSize: number): Promise<{ notifications: Notification[]; totalResults: number }>;
  getNotificationById(kv: any, id: string): Promise<Notification | null>;
}

export interface ISessionRepository {
  saveSession(kv: any, browserClientId: string, sessionData: any, ttlSeconds: number): Promise<void>;
  getSession(kv: any, browserClientId: string): Promise<any | null>;
  deleteSession(kv: any, browserClientId: string): Promise<void>;
}

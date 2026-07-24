import {
  IAuthService,
  IOrderRepository,
  IPaymentRepository,
  INotificationRepository,
  ISessionRepository,
  Order,
  Notification
} from '../domain/types';

export class CreateOrderUseCase {
  constructor(
    private authService: IAuthService,
    private orderRepository: IOrderRepository
  ) {}

  async execute(
    db: any,
    kv: any,
    projectId: string,
    order: any,
    authHeader?: string
  ): Promise<{ orderId: string; order: any }> {
    const orderId = order.id || `ord_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;

    let token: string | null = null;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      token = authHeader.substring(7);
    }

    let userDetails: any = null;
    if (token) {
      userDetails = await this.authService.verifyIdToken(token, projectId, kv);
    }

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

    await this.orderRepository.saveOrder(db, orderId, order);
    return { orderId, order };
  }
}

export class GetOrdersUseCase {
  constructor(
    private authService: IAuthService,
    private orderRepository: IOrderRepository
  ) {}

  async execute(
    db: any,
    kv: any,
    projectId: string,
    authHeader: string | undefined,
    page: number,
    pageSize: number
  ): Promise<{ orders: Order[]; totalResults: number }> {
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new Error('Unauthorized: Missing Authorization Bearer ID Token.');
    }

    const token = authHeader.substring(7);
    const verifiedUser = await this.authService.verifyIdToken(token, projectId, kv);
    if (!verifiedUser) {
      throw new Error('Unauthorized: Invalid Firebase ID Token.');
    }

    const claims = await this.authService.getUserClaims(db, verifiedUser.uid);
    const allOrders = await this.orderRepository.getAllOrders(db);

    const filteredOrders = allOrders.filter((order: Order) => {
      const sellerId = order.payload.seller?.id || order.payload.seller?.identifier || '';
      if (!sellerId) return true; // Global/unassigned orders are visible

      return this.authService.hasStoreAccess(claims, sellerId, ['o', 'm', 's']);
    });

    const totalResults = filteredOrders.length;
    const offset = (page - 1) * pageSize;
    const paginatedOrders = filteredOrders.slice(offset, offset + pageSize);

    return {
      orders: paginatedOrders,
      totalResults
    };
  }
}

export class GetOrderStatusUseCase {
  constructor(private orderRepository: IOrderRepository) {}

  async execute(db: any, orderId: string): Promise<string> {
    const order = await this.orderRepository.getOrderById(db, orderId);
    if (!order) {
      throw new Error('Order not found');
    }
    return order.status;
  }
}

export class RecordPaymentUseCase {
  constructor(
    private authService: IAuthService,
    private orderRepository: IOrderRepository,
    private paymentRepository: IPaymentRepository,
    private notificationRepository: INotificationRepository
  ) {}

  async execute(
    db: any,
    kv: any,
    projectId: string,
    authHeader: string | undefined,
    paymentData: any
  ): Promise<{ paymentId: string; message: string; alreadyPaid?: boolean }> {
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new Error('Unauthorized: Missing Authorization Bearer ID Token.');
    }

    const token = authHeader.substring(7);
    const verifiedUser = await this.authService.verifyIdToken(token, projectId, kv);
    if (!verifiedUser) {
      throw new Error('Unauthorized: Firebase ID Token signature is invalid, expired, or project ID mismatches.');
    }

    const orderId = paymentData.orderId;
    const paymentId = paymentData.id || `pay_${Date.now()}`;

    if (!orderId) {
      throw new Error('Missing required field: orderId');
    }

    const order = await this.orderRepository.getOrderById(db, orderId);
    if (!order) {
      throw new Error('Order ID does not exist in records');
    }

    const sellerId = order.payload.seller?.id || order.payload.seller?.identifier || '';
    if (sellerId) {
      const claims = await this.authService.getUserClaims(db, verifiedUser.uid);
      if (!this.authService.hasStoreAccess(claims, sellerId, ['o', 'm'])) {
        throw new Error('Forbidden: You do not have sufficient permissions (Owner/Moderator) to record payments for this store.');
      }
    }

    // Idempotency check: reject duplicate payments if already paid
    if (order.status === 'PAID') {
      return { paymentId, message: 'Order already recorded as PAID. Payment check bypassed.', alreadyPaid: true };
    }

    // Record payment & update order status to PAID transactionally
    await this.paymentRepository.recordPayment(db, paymentId, orderId, paymentData);

    // Save notification
    const fcmNotificationId = paymentData.notificationId || paymentId;
    const notificationObj: Notification = {
      id: fcmNotificationId,
      title: 'Payment Success',
      body: `Payment for Order ${orderId} has been successfully recorded.`,
      created_at: new Date().toISOString()
    };

    await this.notificationRepository.saveNotification(kv, notificationObj);

    return { paymentId, message: 'Payment recorded and order status set to PAID.' };
  }
}

export class GetNotificationsUseCase {
  constructor(private notificationRepository: INotificationRepository) {}

  async execute(kv: any, page: number, pageSize: number): Promise<{ notifications: Notification[]; totalResults: number }> {
    return this.notificationRepository.getNotifications(kv, page, pageSize);
  }
}

export class GetNotificationByIdUseCase {
  constructor(private notificationRepository: INotificationRepository) {}

  async execute(kv: any, id: string): Promise<Notification> {
    const notification = await this.notificationRepository.getNotificationById(kv, id);
    if (!notification) {
      throw new Error('Notification not found');
    }
    return notification;
  }
}

export class SaveSessionUseCase {
  constructor(private sessionRepository: ISessionRepository) {}

  async execute(kv: any, browserClientId: string, sessionData: any): Promise<void> {
    if (!browserClientId || !sessionData) {
      throw new Error('Missing required fields: browserClientId or sessionData');
    }
    // Persist session to KV with optional 7 days expiration (604800 seconds)
    await this.sessionRepository.saveSession(kv, browserClientId, sessionData, 604800);
  }
}

export class GetSessionUseCase {
  constructor(private sessionRepository: ISessionRepository) {}

  async execute(kv: any, browserClientId: string): Promise<any> {
    const session = await this.sessionRepository.getSession(kv, browserClientId);
    if (!session) {
      throw new Error('Session not found or expired');
    }
    return session;
  }
}

export class DeleteSessionUseCase {
  constructor(private sessionRepository: ISessionRepository) {}

  async execute(kv: any, browserClientId: string): Promise<void> {
    await this.sessionRepository.deleteSession(kv, browserClientId);
  }
}

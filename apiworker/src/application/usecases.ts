import {
  IAuthService,
  IOrderRepository,
  IPaymentRepository,
  INotificationRepository,
  ISessionRepository,
  IUserClaimsRepository,
  Order,
  Notification,
  UserClaims
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
    private orderRepository: IOrderRepository,
    private userClaimsRepository: IUserClaimsRepository
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

    const claims = await this.userClaimsRepository.getUserClaims(db, verifiedUser.uid);
    const allOrders = await this.orderRepository.getAllOrders(db);

    const filteredOrders = allOrders.filter((order: Order) => {
      const sellerId = order.payload.seller?.id || order.payload.seller?.identifier || '';
      if (!sellerId) return true; // Global/unassigned orders are visible

      // Check access: must be owner, moderator, or staff
      return (
        claims.owners.includes(sellerId) ||
        claims.moderators.includes(sellerId) ||
        claims.staffs.includes(sellerId)
      );
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
    private notificationRepository: INotificationRepository,
    private userClaimsRepository: IUserClaimsRepository
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
      const claims = await this.userClaimsRepository.getUserClaims(db, verifiedUser.uid);

      // Verification check: only Owner or Moderator can record payments for a store
      const hasAccess = claims.owners.includes(sellerId) || claims.moderators.includes(sellerId);
      if (!hasAccess) {
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

/**
 * Usecase: ManageUserClaimsUseCase
 * Enforces business logic: only owners of a specific Business/Store ID can add/remove moderators and staff for that store.
 */
export class ManageUserClaimsUseCase {
  constructor(
    private authService: IAuthService,
    private userClaimsRepository: IUserClaimsRepository
  ) {}

  async execute(
    db: any,
    kv: any,
    projectId: string,
    authHeader: string | undefined,
    params: {
      targetUid: string;
      businessId: string;
      role: 'moderator' | 'staff';
      action: 'add' | 'remove';
    }
  ): Promise<{ success: boolean; message: string; claims: UserClaims }> {
    const { targetUid, businessId, role, action } = params;

    if (!targetUid || !businessId || !role || !action) {
      throw new Error('Missing required fields: targetUid, businessId, role, or action');
    }

    if (role !== 'moderator' && role !== 'staff') {
      throw new Error('Invalid role: must be moderator or staff');
    }

    if (action !== 'add' && action !== 'remove') {
      throw new Error('Invalid action: must be add or remove');
    }

    // 1. Authenticate Requester
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new Error('Unauthorized: Missing Authorization Bearer ID Token.');
    }

    const token = authHeader.substring(7);
    const verifiedRequester = await this.authService.verifyIdToken(token, projectId, kv);
    if (!verifiedRequester) {
      throw new Error('Unauthorized: Invalid Firebase ID Token.');
    }

    // 2. Load Requester's claims to verify Owner privilege for the specified businessId
    const requesterClaims = await this.userClaimsRepository.getUserClaims(db, verifiedRequester.uid);
    const isOwner = requesterClaims.owners.includes(businessId);
    if (!isOwner) {
      throw new Error('Forbidden: Only owners of this business can manage moderator or staff roles.');
    }

    // 3. Load Target user's claims
    const targetClaims = await this.userClaimsRepository.getUserClaims(db, targetUid);

    // 4. Update Target user's list
    if (action === 'add') {
      if (role === 'moderator') {
        if (!targetClaims.moderators.includes(businessId)) {
          targetClaims.moderators.push(businessId);
        }
      } else {
        if (!targetClaims.staffs.includes(businessId)) {
          targetClaims.staffs.push(businessId);
        }
      }
    } else {
      if (role === 'moderator') {
        targetClaims.moderators = targetClaims.moderators.filter(id => id !== businessId);
      } else {
        targetClaims.staffs = targetClaims.staffs.filter(id => id !== businessId);
      }
    }

    // 5. Persist updated target user claims in D1 database
    await this.userClaimsRepository.saveUserClaims(db, targetClaims);

    return {
      success: true,
      message: `Successfully ${action === 'add' ? 'added to' : 'removed from'} ${role} role for business ${businessId}.`,
      claims: targetClaims
    };
  }
}

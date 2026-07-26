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

import {
  UnauthorizedError,
  ForbiddenError,
  NotFoundError,
  ValidationError
} from '../domain/exceptions';

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
    // 1. Strict Payload Structural Validation
    if (!order || typeof order !== 'object') {
      throw new ValidationError('Invalid order payload: must be a valid JSON object.');
    }

    if (order['@type'] !== 'Order') {
      throw new ValidationError('Invalid order payload: "@type" must be "Order".');
    }

    if (!order.orderedItem) {
      throw new ValidationError('Invalid order payload: "orderedItem" is required.');
    }

    const items = Array.isArray(order.orderedItem) ? order.orderedItem : [order.orderedItem];
    if (items.length === 0) {
      throw new ValidationError('Invalid order payload: "orderedItem" must contain at least one item.');
    }

    for (const item of items) {
      if (!item.orderedItem) {
        throw new ValidationError('Invalid order item: each item must reference a product or service ("orderedItem").');
      }
      const quantity = item.orderQuantity;
      if (quantity === undefined || quantity === null || Number(quantity) <= 0) {
        throw new ValidationError('Invalid order item quantity: must be greater than zero.');
      }
    }

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
      throw new UnauthorizedError('Missing Authorization Bearer ID Token.');
    }

    const token = authHeader.substring(7);
    const verifiedUser = await this.authService.verifyIdToken(token, projectId, kv);
    if (!verifiedUser) {
      throw new UnauthorizedError('Invalid Firebase ID Token.');
    }

    const claims = await this.userClaimsRepository.getUserClaims(db, verifiedUser.uid);
    const allOrders = await this.orderRepository.getAllOrders(db);

    const filteredOrders = allOrders.filter((order: Order) => {
      const sellerId = order.payload.seller?.id || order.payload.seller?.identifier || '';
      if (!sellerId) return true; // Global/unassigned orders are visible

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
      throw new NotFoundError('Order not found');
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
      throw new UnauthorizedError('Missing Authorization Bearer ID Token.');
    }

    const token = authHeader.substring(7);
    const verifiedUser = await this.authService.verifyIdToken(token, projectId, kv);
    if (!verifiedUser) {
      throw new UnauthorizedError('Firebase ID Token signature is invalid, expired, or project ID mismatches.');
    }

    // Strict Payment Payload Validation
    if (!paymentData || typeof paymentData !== 'object') {
      throw new ValidationError('Invalid payment payload: must be a valid JSON object.');
    }

    const orderId = paymentData.orderId;
    const paymentId = paymentData.id || `pay_${Date.now()}`;

    if (!orderId || typeof orderId !== 'string' || orderId.trim() === '') {
      throw new ValidationError('Missing or invalid required field: orderId');
    }

    const order = await this.orderRepository.getOrderById(db, orderId);
    if (!order) {
      throw new ValidationError('Order ID does not exist in records');
    }

    const sellerId = order.payload.seller?.id || order.payload.seller?.identifier || '';
    if (sellerId) {
      const claims = await this.userClaimsRepository.getUserClaims(db, verifiedUser.uid);

      const hasAccess = claims.owners.includes(sellerId) || claims.moderators.includes(sellerId);
      if (!hasAccess) {
        throw new ForbiddenError('You do not have sufficient permissions (Owner/Moderator) to record payments for this store.');
      }
    }

    if (order.status === 'PAID') {
      return { paymentId, message: 'Order already recorded as PAID. Payment check bypassed.', alreadyPaid: true };
    }

    await this.paymentRepository.recordPayment(db, paymentId, orderId, paymentData);

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
      throw new NotFoundError('Notification not found');
    }
    return notification;
  }
}

export class SaveSessionUseCase {
  constructor(private sessionRepository: ISessionRepository) {}

  async execute(kv: any, browserClientId: string, sessionData: any): Promise<void> {
    if (!browserClientId || !sessionData) {
      throw new ValidationError('Missing required fields: browserClientId or sessionData');
    }
    await this.sessionRepository.saveSession(kv, browserClientId, sessionData, 604800);
  }
}

export class GetSessionUseCase {
  constructor(private sessionRepository: ISessionRepository) {}

  async execute(kv: any, browserClientId: string): Promise<any> {
    const session = await this.sessionRepository.getSession(kv, browserClientId);
    if (!session) {
      throw new NotFoundError('Session not found or expired');
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
      throw new ValidationError('Missing required fields: targetUid, businessId, role, or action');
    }

    if (role !== 'moderator' && role !== 'staff') {
      throw new ValidationError('Invalid role: must be moderator or staff');
    }

    if (action !== 'add' && action !== 'remove') {
      throw new ValidationError('Invalid action: must be add or remove');
    }

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedError('Missing Authorization Bearer ID Token.');
    }

    const token = authHeader.substring(7);
    const verifiedRequester = await this.authService.verifyIdToken(token, projectId, kv);
    if (!verifiedRequester) {
      throw new UnauthorizedError('Invalid Firebase ID Token.');
    }

    const requesterClaims = await this.userClaimsRepository.getUserClaims(db, verifiedRequester.uid);
    const isOwner = requesterClaims.owners.includes(businessId);
    if (!isOwner) {
      throw new ForbiddenError('Only owners of this business can manage moderator or staff roles.');
    }

    const targetClaims = await this.userClaimsRepository.getUserClaims(db, targetUid);

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

    await this.userClaimsRepository.saveUserClaims(db, targetClaims);

    return {
      success: true,
      message: `Successfully ${action === 'add' ? 'added to' : 'removed from'} ${role} role for business ${businessId}.`,
      claims: targetClaims
    };
  }
}

/**
 * Usecase: RegisterOwnerUseCase
 * Bootstraps store ownership: allows the first caller to securely claim ownership of a businessId if no owner is registered yet.
 */
export class RegisterOwnerUseCase {
  constructor(
    private authService: IAuthService,
    private userClaimsRepository: IUserClaimsRepository
  ) {}

  async execute(
    db: any,
    kv: any,
    projectId: string,
    authHeader: string | undefined,
    businessId: string
  ): Promise<{ success: boolean; message: string; claims: UserClaims }> {
    if (!businessId || typeof businessId !== 'string' || businessId.trim() === '') {
      throw new ValidationError('Missing or invalid required parameter: businessId');
    }

    // 1. Authenticate Requester
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedError('Missing Authorization Bearer ID Token.');
    }

    const token = authHeader.substring(7);
    const verifiedRequester = await this.authService.verifyIdToken(token, projectId, kv);
    if (!verifiedRequester) {
      throw new UnauthorizedError('Invalid Firebase ID Token.');
    }

    // 2. Check if this businessId already has an owner
    const currentOwnerUid = await this.userClaimsRepository.getOwnerOfBusiness(db, businessId);
    if (currentOwnerUid !== null) {
      if (currentOwnerUid === verifiedRequester.uid) {
        // Already the owner, return existing claims cleanly
        const currentClaims = await this.userClaimsRepository.getUserClaims(db, verifiedRequester.uid);
        return {
          success: true,
          message: `You are already the registered owner of business ${businessId}.`,
          claims: currentClaims
        };
      }
      throw new ForbiddenError(`Business ${businessId} already has a registered owner. Ownership cannot be reassigned.`);
    }

    // 3. Register requester as Owner
    const requesterClaims = await this.userClaimsRepository.getUserClaims(db, verifiedRequester.uid);
    if (!requesterClaims.owners.includes(businessId)) {
      requesterClaims.owners.push(businessId);
    }

    // 4. Save updated claims in D1 database
    await this.userClaimsRepository.saveUserClaims(db, requesterClaims);

    return {
      success: true,
      message: `Successfully registered as the owner of business ${businessId}.`,
      claims: requesterClaims
    };
  }
}

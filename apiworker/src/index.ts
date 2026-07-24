import { Hono } from 'hono';
import { cors } from 'hono/cors';

import { AuthService } from './infrastructure/AuthService';
import { DatabaseBootstrapper } from './infrastructure/DatabaseBootstrapper';
import { OrderRepository } from './infrastructure/OrderRepository';
import { PaymentRepository } from './infrastructure/PaymentRepository';
import { NotificationRepository } from './infrastructure/NotificationRepository';
import { SessionRepository } from './infrastructure/SessionRepository';

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
} from './application/usecases';

import { configureRoutes, Env } from './presentation/controllers';

const app = new Hono<{ Bindings: Env }>();

// Enable CORS for custom domain and Blogger subdomain compatibility
app.use('*', cors({
  origin: '*',
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowHeaders: ['Content-Type', 'Authorization', 'X-Antinna-Client-Id'],
  maxAge: 86400,
}));

// Instantiate Core Services & Repositories
const authService = new AuthService();
const bootstrapper = new DatabaseBootstrapper();
const orderRepository = new OrderRepository();
const paymentRepository = new PaymentRepository();
const notificationRepository = new NotificationRepository();
const sessionRepository = new SessionRepository();

// Instantiate Use Cases
const createOrderUseCase = new CreateOrderUseCase(authService, orderRepository);
const getOrdersUseCase = new GetOrdersUseCase(authService, orderRepository);
const getOrderStatusUseCase = new GetOrderStatusUseCase(orderRepository);
const recordPaymentUseCase = new RecordPaymentUseCase(authService, orderRepository, paymentRepository, notificationRepository);
const getNotificationsUseCase = new GetNotificationsUseCase(notificationRepository);
const getNotificationByIdUseCase = new GetNotificationByIdUseCase(notificationRepository);
const saveSessionUseCase = new SaveSessionUseCase(sessionRepository);
const getSessionUseCase = new GetSessionUseCase(sessionRepository);
const deleteSessionUseCase = new DeleteSessionUseCase(sessionRepository);

// Wire Presentation and Routing Layers
configureRoutes(
  app,
  bootstrapper,
  createOrderUseCase,
  getOrdersUseCase,
  getOrderStatusUseCase,
  recordPaymentUseCase,
  getNotificationsUseCase,
  getNotificationByIdUseCase,
  saveSessionUseCase,
  getSessionUseCase,
  deleteSessionUseCase
);

// Favicon redirect
app.get('/favicon.ico', (c) => {
  return c.redirect('https://www.antinna.in/favicon.ico', 301);
});

// Root welcome message
app.get('/', (c) => {
  return c.text('Welcome to Antinna Ecommerce API Server powered by Hono on Cloudflare Workers!');
});

export default app;

/**
 * Welcome to Cloudflare Workers!
 *
 * This is a template for a Scheduled Worker: a Worker that can run on a
 * configurable interval:
 * https://developers.cloudflare.com/workers/platform/triggers/cron-triggers/
 *
 * - Run `npm run dev` in your terminal to start a development server
 * - Run `curl "http://localhost:8787/__scheduled?cron=*+*+*+*+*"` to see your Worker in action
 * - Run `npm run deploy` to publish your Worker
 *
 * Bind resources to your Worker in `wrangler.jsonc`. After adding bindings, a type definition for the
 * `Env` object can be regenerated with `npm run cf-typegen`.
 *
 * Learn more at https://developers.cloudflare.com/workers/
 */

import { Hono } from 'hono';

// export interface Env {
// 	// Example binding to a KV namespace:
// 	// MY_KV_NAMESPACE: KVNamespace;

// 	// Example binding to a Durable Object:
// 	// MY_DURABLE_OBJECT: DurableObjectNamespace;

// 	// Example binding to a R2 bucket:
// 	// MY_R2_BUCKET: R2Bucket;

// 	// Example binding to a Queue:
// 	// MY_QUEUE: Queue;

// 	// Example binding to a D1 database:
// 	// MY_D1_DATABASE: D1Database;
// }

const app = new Hono<{ Bindings: Env }>();

// 		if (url.pathname === '/favicon.ico') {
// 			return Response.redirect('https://www.antinna.in/favicon.ico', 301);
// 		}

// app.get('/', (c) => c.text('Hello Hono!'));

export default app;

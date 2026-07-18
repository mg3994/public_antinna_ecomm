# Antinna Monorepo

> A collection of projects that together power the Antinna Blogger ecosystem, combining a Schema.org-first eCommerce engine, Blogger theme generation, Cloudflare Workers, and supporting backend services.

---

# Repository Structure

```text
.
├── .github/
├── antinna-blogger-engine/
├── antinna-fb-worker/
├── apiworker/
├── blogger_theme/
├── clasp/
└── todo/
```

---

# Overall Architecture

```text
                    ┌─────────────────────────┐
                    │ antinna-blogger-engine  │
                    │  Core Ecommerce Engine  │
                    └────────────┬────────────┘
                                 │
                     IIFE JavaScript Release
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │     blogger_theme       │
                    │ Dart Theme Generator    │
                    └────────────┬────────────┘
                                 │
                          Blogger Theme XML
                                 │
                                 ▼
                           Blogger Website
                    ┌────────────┴────────────┐
                    │                         │
                    ▼                         ▼
          Firebase Worker            Backend APIs
    antinna-fb-worker               apiworker(Hono)
```

---

# Project Details

---

## .github

Contains all GitHub workflows, release automation, CI/CD pipelines, publishing processes, and repository automation.

The workflows are intentionally designed to execute **in sequence**, not independently.

## Planned Workflow Order

```text
1.
antinna-blogger-engine

        │
        │ Build
        │ Test
        │ Release
        ▼

GitHub Release
(IIFE Asset)

        │
        ▼

2.
blogger_theme

Downloads latest release

        │

Generates

theme.xml

        │

Publishes
```

### Planned Responsibilities

- Code quality
- Formatting
- Static analysis
- Unit tests
- Build IIFE bundle
- Create GitHub Release
- Trigger downstream workflows
- Generate Blogger Theme
- Publish release artifacts

---

## antinna-blogger-engine

This is the **heart of the entire project**.

Everything ultimately depends on this package.

### Purpose

Develop a JavaScript engine that powers Blogger websites.

Unlike traditional Blogger templates, this engine is built around:

- Schema.org
- JSON-LD
- Structured Data
- SEO-first rendering
- Ecommerce components

The engine is compiled into a single **IIFE JavaScript bundle** that is embedded inside Blogger XML templates.

### Current Status

The existing implementation will be completely rewritten.

The new architecture will focus on:

- Modular design
- Plugin architecture
- Tree-shakable features
- Better extensibility
- Cleaner APIs
- Strong typing
- Better performance

### Long-term Vision

Instead of thinking in terms of HTML widgets, every page should be composed of Schema.org entities.

Examples:

- Product
- Collection
- Breadcrumb
- Organization
- Person
- BlogPosting
- Offer
- AggregateRating
- FAQ
- Review

Everything should be generated from structured data.

---

## antinna-fb-worker

Cloudflare Worker responsible for Firebase Push Notifications.

### Purpose

Blogger cannot normally host a Firebase service worker at the root path.

This worker solves that limitation by exposing:

```
/firebase-messaging-sw.js
```

through Cloudflare.

### Responsibilities

- Proxy Firebase Service Worker
- Cache responses
- Serve correct headers
- Handle service worker routing
- Work seamlessly with Blogger

---

## apiworker

Cloudflare Worker backend built with **Hono**.

This will become the primary backend service.

---

### Planned Technologies

- Cloudflare Workers
- Hono
- Cloudflare D1
- Cloudflare KV (optional)
- Cloudflare R2 (future)
- Cloudflare Queues (future)

---

### Responsibilities

API endpoints

Authentication

Orders

Payments

Products

Licenses

Downloads

Customer validation

---

### Database

Cloudflare D1

Initial tables may include:

- Orders
- Payments
- Customers
- Products
- Downloads
- Licenses

---

### Payment Safety

One important design goal is preventing duplicate payments.

Example flow:

```
Create Order

      │

Check Database

      │

Already Paid?

 ┌───────────────┐
 │               │
Yes             No
 │               │
 │          Continue
 │          Payment
 │
Return Success
```

Before accepting any payment:

- Verify Order ID exists
- Check payment status
- Reject duplicate payments
- Ensure idempotent payment processing

---

## blogger_theme

Dart project responsible for generating the Blogger XML template.

It consumes the output from:

```
antinna-blogger-engine
```

The build process is controlled by:

```
bin/main.dart
```

---

### Responsibilities

- Download latest engine build
- Embed generated IIFE
- Inject Blogger XML
- Generate widgets
- Produce final `theme.xml`

Final output:

```
theme.xml
```

This file is uploaded directly into Blogger.

---

## clasp

Google Apps Script project.

This project is largely complete.

Current use cases include:

- Google Maps services
- Apps Script utilities
- Google Workspace integrations

Future additions may include:

- Blogger automation
- Spreadsheet integrations
- Admin utilities

---

## todo

Contains documentation, ideas, research, and future plans.

Suggested structure:

```text
todo/
├── ideas/
├── architecture/
├── roadmap/
├── research/
├── schema/
├── ecommerce/
├── cloudflare/
└── blogger/
```

Possible markdown files:

```
ProjectGuide.md

architecture.md

backend.md

payments.md

roadmap.md

seo.md

schema.md

theme-generator.md

firebase.md

worker.md

future-features.md
```

---

# Build Dependency

```text
antinna-blogger-engine
          │
          ▼
GitHub Release (IIFE)

          │
          ▼
blogger_theme

          │
          ▼
theme.xml

          │
          ▼
Blogger
```

---

# Future Goals

- Completely modular Blogger engine
- Schema.org-first architecture
- Full Ecommerce support
- Cloudflare-native backend
- Automatic Blogger theme generation
- GitHub Actions release pipeline
- Zero-manual deployment
- Strong SEO foundation
- Extensible plugin ecosystem
- Payment-safe backend
- Automated documentation
- High-performance Blogger templates

---

# Development Philosophy

The entire ecosystem should follow a few core principles:

- Schema.org is the source of truth.
- Everything should be modular and reusable.
- Automation should replace manual deployment wherever possible.
- GitHub Actions should orchestrate releases across dependent projects.
- Cloudflare Workers should provide lightweight, globally distributed backend services.
- Blogger themes should be generated, not manually maintained.
- Every component should remain independently testable while integrating seamlessly into the larger ecosystem.

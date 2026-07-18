```fs
src/
│
├── app/
││
│├── bootstrap.ts
│├── routes.ts
│├── do_get.ts
│├── do_post.ts
│├── do_put.ts
│├── do_delete.ts
│└── app.ts
│
├── core/
││
│├── auth/
││ ├── auth_guard.ts
││ ├── bearer_token.ts
││ ├── api_key.ts
││ └── permissions.ts
││
│├── batch/
││ ├── batch_reader.ts
││ ├── batch_writer.ts
││ ├── batch_delete.ts
││ └── batch_update.ts
││
│├── builders/
││ ├── response_builder.ts
││ ├── error_builder.ts
││ ├── pagination_builder.ts
││ └── request_builder.ts
││
│├── cache/
││ ├── cache_manager.ts
││ ├── cache_service.ts
││ ├── cache_keys.ts
││ └── cache_scope.ts
││
│├── clock/
││ └── clock.ts
││
│├── constants/
││ ├── mime_type.ts
││ ├── status_code.ts
││ ├── content_type.ts
││ └── headers.ts
││
│├── database/
││ ├── spreadsheet.ts
││ ├── sheet.ts
││ ├── range.ts
││ ├── row.ts
││ ├── column.ts
││ └── transaction.ts
││
│├── decorators/
││ ├── cached.ts
││ ├── locked.ts
││ ├── retry.ts
││ └── timed.ts
││
│├── enums/
││ ├── cache_scope.ts
││ ├── lock_type.ts
││ ├── property_scope.ts
││ └── log_level.ts
││
│├── exceptions/
││ ├── api_error.ts
││ ├── bad_request_error.ts
││ ├── unauthorized_error.ts
││ ├── forbidden_error.ts
││ ├── not_found_error.ts
││ ├── validation_error.ts
││ ├── spreadsheet_error.ts
││ └── conflict_error.ts
││
│├── handler/
││ ├── execute.ts
││ ├── request_handler.ts
││ ├── response_handler.ts
││ └── exception_handler.ts
││
│├── http/
││ ├── request.ts
││ ├── response.ts
││ ├── query.ts
││ ├── body.ts
││ ├── params.ts
││ └── headers.ts
││
│├── json/
││ └── json.ts
││
│├── lock/
││ ├── lock_manager.ts
││ ├── lock.ts
││ ├── sheet_lock.ts
││ ├── document_lock.ts
││ ├── script_lock.ts
││ └── user_lock.ts
││
│├── logger/
││ ├── logger.ts
││ ├── console_logger.ts
││ ├── sheet_logger.ts
││ └── execution_logger.ts
││
│├── metrics/
││ ├── profiler.ts
││ ├── stopwatch.ts
││ └── execution_time.ts
││
│├── middleware/
││ ├── auth.ts
││ ├── logging.ts
││ ├── validator.ts
││ └── cors.ts
││
│├── models/
││ ├── api_response.ts
││ ├── api_error.ts
││ ├── pagination.ts
││ ├── page.ts
││ ├── metadata.ts
││ └── result.ts
││
│├── properties/
││ ├── property_manager.ts
││ ├── script_properties.ts
││ ├── user_properties.ts
││ └── document_properties.ts
││
│├── retry/
││ ├── retry.ts
││ ├── retry_options.ts
││ └── exponential_backoff.ts
││
│├── router/
││ ├── router.ts
││ ├── route.ts
││ ├── endpoint.ts
││ └── method.ts
││
│├── security/
││ ├── jwt.ts
││ ├── signature.ts
││ ├── hmac.ts
││ └── hash.ts
││
│├── storage/
││ ├── drive.ts
││ ├── blob.ts
││ └── file.ts
││
│├── trigger/
││ ├── trigger_manager.ts
││ ├── cron.ts
││ └── scheduler.ts
││
│├── utils/
││ ├── arrays.ts
││ ├── strings.ts
││ ├── objects.ts
││ ├── numbers.ts
││ ├── dates.ts
││ ├── uuid.ts
││ ├── random.ts
││ ├── guards.ts
││ └── sleep.ts
││
│├── validation/
││ ├── validator.ts
││ ├── rules.ts
││ ├── required.ts
││ ├── email.ts
││ ├── regex.ts
││ ├── number.ts
││ ├── min.ts
││ ├── max.ts
││ └── custom.ts
││
│└── wrappers/
│  ├── gmail.ts
│  ├── calendar.ts
│  ├── sheets.ts
│  ├── drive.ts
│  ├── docs.ts
│  ├── maps.ts
│  ├── forms.ts
│  ├── contacts.ts
│  ├── properties.ts
│  └── cache.ts
│
├── features/
│
├── shared/
│├── config/
│├── dto/
│├── interfaces/
│├── types/
│└── extensions/
│
└── main.ts
```


```mermaid
Time
 │
 ▼
Google Apps Script Trigger
 │
 ▼
Scheduler
 │
 ▼
JobRunner
 │
 ▼
MonthlyGstJob
 │
 ▼
Spreadsheet
```


## Every month on the last day at 11:55 PM you want
```meraid
Sales

↓

Create GST Sheet

↓

Copy template

↓

Rename

↓

Lock

↓

Notify Admin

```
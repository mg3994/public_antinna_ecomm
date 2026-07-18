# clasp Integration Guide

## 1. Login

Run:

> clasp login

## 2. Create a new Apps Script project

Run:

> clasp create-script --title Map

Expected output:

- Created new script: https://script.google.com/d/1MTPQrXDbmQnCYKbeqVoaJ9z90wnXL2cxQKQLkgDiExJS1hpZjJQ1zeIQ/edit
- └─ appsscript.json
- Cloned one file..

## 3. Project structure

Move `appsscript.json` into the `dist` directory.

### dist/appsscript.json

```json
{
  "timeZone": "Asia/Kolkata",
  "dependencies": {},
  "exceptionLogging": "STACKDRIVER",
  "runtimeVersion": "V8",
  "webapp": {
    "executeAs": "USER_DEPLOYING",
    "access": "ANYONE_ANONYMOUS"
  }
}
```

### .clasp.json

Update or create `.clasp.json` with:

```json
{
  "scriptId": "1MTPQrXDbmQnCYKbeqVoaJ9z90wnXL2cxQKQLkgDiExJS1hpZjJQ1zeIQ",
  "rootDir": "./dist",
  "scriptExtensions": [
    ".js",
    ".gs"
  ],
  "htmlExtensions": [
    ".html"
  ],
  "jsonExtensions": [
    ".json"
  ],
  "filePushOrder": [],
  "skipSubdirectories": false
}
```

## 4. Push files

Run:

> clasp push

Expected output:

- ✔ Manifest file has been updated. Do you want to push and overwrite? Yes
- Pushed 3 files at 10:14:51 am.
  - dist/appsscript.json
  - dist/main.js
  - dist/maps_code.js

## 5. Deployment

To create a deployment:

> clasp create-deployment

Example response:

- Deployed AKfycbyca4Xz_AE6Om1okIMf0TQ9EE9uIifQcVZhsDwnZK0K4weG7VD0w3jEzM0aCcuBeoWIIA @1

For redeploy:

> clasp deploy -i AKfycbyca4Xz_AE6Om1okIMf0TQ9EE9uIifQcVZhsDwnZK0K4weG7VD0w3jEzM0aCcuBeoWIIA

Or simply: (new version)

> clasp deploy


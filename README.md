# GSMA — Grocery Store Management App

Offline-first Flutter POS and back-office for grocery stores. Uses **GetX**, **Isar**, and **Firebase**.

## Requirements

- Flutter SDK 3.9+
- Dart 3.9+
- Android Studio / Xcode for device builds

## Project setup

```bash
cd gsma
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run
```

## Firebase setup (Android linked)

Project **`gsms-d944d`** is wired for Android:

- `lib/firebase_options.dart` — FlutterFire Dart config
- `android/app/google-services.json` — Android SDK config
- `firebase.json` — Firestore rules/indexes paths + FlutterFire metadata

Gradle applies **Google Services** and **Crashlytics** (from FlutterFire). Run on device:

```bash
flutter run
```

**Console checklist:**

1. Enable **Authentication → Email/Password**.
2. Deploy Firestore rules (required for first-time setup):

```bash
firebase deploy --only firestore:rules
```

3. On the device, open the app → **Set up your store** (first launch) to create the owner account, store record, and Firestore profile in one step. Staff join via **Team → Add** (owner) or **Join store with invite code** on the login screen.

Cached sessions work offline after first login.

### Add team members (in app)

**Owner:** **More → Team → +**

1. **Create account** — email, name, temporary password, role (requires deploying Cloud Functions once):
   ```bash
   cd firebase/functions && npm install && cd ../..
   firebase deploy --only functions,firestore:rules
   ```
2. **Invite code** — generates a 6-character code (valid 7 days). Staff use **Login → Join a store with invite code**, then sign up.

Edit roles/permissions from **Team** → tap a member.

### Auth user document (Firestore)

Manual Console setup is optional; the app creates profiles via **Create account** or **Invite code**. Example document:

```json
{
  "email": "owner@store.com",
  "displayName": "Owner",
  "storeId": "your-store-id",
  "role": "owner",
  "permissions": { "canViewReports": true },
  "isActive": true
}
```

Roles: `owner`, `manager`, `cashier`, `stockManager`, `accountant`. Omitted permissions fall back to role defaults.

### Deploy rules and indexes

```bash
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

Files: `firebase/firestore.rules`, `firebase/firestore.indexes.json`.

## Isar

Collections are defined under `lib/core/database/collections/`. Regenerate after schema changes:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Environments

Set via `SharedPreferences` key `app_environment`: `development` | `staging` | `production` (default: development).

## Build APK

```bash
flutter build apk --release
```

## Architecture

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Implementation phases

| Phase | Module |
|-------|--------|
| 1 | Foundation ✓ |
| 2 | Authentication ✓ |
| 3 | Products & categories ✓ |
| 4 | Inventory ✓ |
| 5 | POS ✓ |
| 6 | Customers & Khata ✓ |
| 7 | Purchases & suppliers ✓ |
| 8 | Expenses & cash ✓ |
| 9 | Reports & analysis ✓ |
| 10 | Offline sync ✓ |
| 11 | Notifications ✓ |
| 12 | Users & permissions ✓ |
| 13 | Audit logs ✓ |
| 14 | Settings & sync queue ✓ |

## Offline sync (overview)

Local writes → Isar → `SyncQueueItem` (`pending`) → `SyncManager` / `FirestoreSyncProcessor` upload to Firestore when online (merge by entity id). Manual **Sync now** on the status banner; auto-sync when connectivity returns. Failed items retry up to 5 attempts then mark `failed`.

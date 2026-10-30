# Ambrogio Grocery

An app to plan your weekly grocery shopping starting from your recipes.

You keep your recipes in the app, choose what you want to cook during the
week, and get a single grocery list for the whole week.

Today the app runs on Android and iOS and stores everything on the device.
A Dart backend for user accounts and sharing data across devices is being
built in `apps/backend`.

## Setup

Requires Flutter (stable) and the SDK of the target platform: the Android
SDK for Android, Xcode and CocoaPods for iOS (see [iOS](#ios)). Check with
`flutter doctor`.

```sh
flutter pub get        # from the repo root, resolves all packages
```

All the commands below run from `apps/mobile`, except the
[Backend](#backend) ones.

## Run

```sh
flutter emulators --launch Pixel_8   # Android, or connect a phone with USB debugging
open -a Simulator                    # iOS
flutter devices                      # lists the device ids
flutter run -d <device id>
```

From IntelliJ, use the `mobile` run configuration and pick the device in the
toolbar (View → Appearance → Toolbar if it's hidden). If a device is missing
from the list but `flutter devices` shows it, restart IntelliJ. Use a full
restart, not hot reload, after changing `main.dart`, the database or the
dependencies.

The app talks to the [backend](#backend) for accounts. It uses
`http://localhost:8080` unless you pass another address:

```sh
flutter run -d <device id> --dart-define=API_URL=http://10.0.2.2:8080       # Android emulator
flutter run -d <device id> --dart-define=API_URL=http://<your Mac's IP>:8080 # a phone on the same Wi-Fi
```

Recipes and grocery lists work without an account or a backend.

These are debug builds: on an iPhone the app only opens while IntelliJ or
`flutter run` is connected. To install a build you can open on its own, see
[Android](#android) and [iOS](#ios).

## Version

The `version` in `pubspec.yaml` is used by both platforms: `1.0.1` is the
version shown to the user, the number after `+` is the build number. Bump the
build number on every release, Android refuses an update without it:

```yaml
version: 1.0.1+2
```

Recipes survive an update as long as the app id stays the same
(`me.mircoporetti.ambrogio_grocery` on Android,
`me.mircoporetti.ambrogioGrocery` on iOS) and, on Android, the APK is signed
with the same key.

## Test

```sh
flutter test
```

Acceptance tests in `test/acceptance/` drive the whole app through its UI
against a real SQLite database. They run headless in a few seconds, no
emulator needed.

After changing database tables in `lib/database/app_database.dart`,
regenerate the drift code and bump `schemaVersion` with a migration:

```sh
dart run build_runner build
```

## Backend

A plain Dart server built on [shelf](https://pub.dev/packages/shelf), with
a Postgres database and S3-compatible photo storage (Cloudflare R2 in
production, [SeaweedFS](https://github.com/seaweedfs/seaweedfs) locally).
Requires Docker for the local database and photo storage. The commands
run from `apps/backend`.

```sh
docker compose up -d --wait       # Postgres on port 5433, SeaweedFS S3 on 8333
dart run bin/server.dart          # listens on port 8080, or $PORT
curl localhost:8080/health        # {"status":"ok"}
dart test                         # acceptance tests over real HTTP, Postgres and SeaweedFS
docker compose down               # stop them (data is kept)
```

`dart test` starts Postgres and SeaweedFS itself if they aren't running
(Docker must be running). Each test creates its own empty database and drops
it afterwards; photos go to the `ambrogio-photos-test` bucket under each
test's new accounts. Both keep running after the tests; stop them with
`docker compose down`.

The server reads its configuration from environment variables. The defaults
match `compose.yaml`:

| Variable      | Default     |
|---------------|-------------|
| `JWT_SECRET`  | none, required: signs access tokens, at least 32 random bytes (`openssl rand -base64 48`) |
| `PORT`        | `8080`      |
| `DB_HOST`     | `localhost` |
| `DB_PORT`     | `5433`      |
| `DB_NAME`     | `ambrogio`  |
| `DB_USER`     | `ambrogio`  |
| `DB_PASSWORD` | `ambrogio`  |
| `DB_SSL`      | `disable` for localhost, `require` otherwise |
| `S3_ENDPOINT` | `http://localhost:8333`; on R2 `https://<account id>.r2.cloudflarestorage.com` |
| `S3_REGION`   | `us-east-1`; on R2 `auto` |
| `S3_BUCKET`   | `ambrogio-photos` |
| `S3_ACCESS_KEY_ID`     | `ambrogio` |
| `S3_SECRET_ACCESS_KEY` | `ambrogio-secret` |

Photos never pass through the server: it signs short-lived URLs (15
minutes) and the app uploads and downloads straight from the bucket. The
bucket stays private. Photos are stored at
`accounts/<account id>/photos/<photo id>`, and deleted when no recipe uses
them any more.

After changing tables in `lib/database/backend_database.dart`, run
`dart run build_runner build` and bump `schemaVersion` with a migration.

The backend runs on the homelab k3s at
`https://api-ambrogio.mircoporetti.me` and deploys on every push to `main`
that touches it. Setup, secrets and rollback:
[apps/backend/k8s/README.md](apps/backend/k8s/README.md).

## Android

### Release an APK

#### One-time setup: signing key

Android only accepts an app update if it is signed with the same key as the
installed version. Losing the key means uninstalling the app, which deletes
all recipes on the phone. Back up the keystore and its password.

1. Create the keystore, outside the repo:

   ```sh
   keytool -genkey -v -keystore ~/ambrogio-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Create `android/key.properties` (gitignored, never commit it):

   ```properties
   storePassword=<keystore password>
   keyPassword=<key password>
   keyAlias=upload
   storeFile=/Users/<you>/ambrogio-upload.jks
   ```

Without `key.properties` the release build falls back to the debug key, with
a warning. That APK can't update one signed with the real key.

#### Build and install

1. Bump the version in `pubspec.yaml` (see [Version](#version)).

2. Build:

   ```sh
   flutter build apk --release
   ```

   Output: `build/app/outputs/flutter-apk/app-release.apk`

3. Install it, either:
   - with the phone connected over USB: `flutter install`
   - or copy the APK to the phone and open it (allow "Install unknown apps"
     when asked)

#### Verify which key signed the APK

```sh
"$(ls -d ~/Library/Android/sdk/build-tools/*/ | tail -1)apksigner" verify --print-certs build/app/outputs/flutter-apk/app-release.apk
```

The certificate should show the name you entered in `keytool`. If it shows
`CN=Android Debug`, the APK was signed with the debug key: check
`android/key.properties`.

To see the fingerprint of your keystore and compare it with the APK's
SHA-256:

```sh
keytool -list -v -keystore ~/ambrogio-upload.jks -alias upload
```

## iOS

Builds need Xcode installed, but you only open it once to sign in with
your Apple ID. Everything else runs from IntelliJ or the terminal.

### One-time setup on the Mac

```sh
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
xcodebuild -downloadPlatform iOS     # simulator runtime, a few GB
brew install cocoapods               # needed by the plugins
flutter doctor                       # Xcode should be green
```

### Run on the simulator

```sh
open -a Simulator
```

Then pick the iPhone in the IntelliJ device dropdown and run the `mobile`
configuration, or run `flutter run` from `apps/mobile`.

### Run on an iPhone

1. On the iPhone: Settings → Privacy & Security → Developer Mode → on
   (the phone restarts).
2. Connect it with a cable and tap "Trust this computer".
3. Signing, once: open Xcode → Settings → Accounts, add your Apple ID (a
   free account works), then Manage Certificates → + → Apple Development.
   Close Xcode.
4. If the build asks for a development team, set your Team ID (shown in
   Xcode → Settings → Accounts) as `DEVELOPMENT_TEAM = <Team ID>;` in the
   Runner build settings in `ios/Runner.xcodeproj/project.pbxproj`.
5. Pick the phone in IntelliJ and run. Wireless works but is slow; if the
   phone stays on a white screen, use the cable.
6. First launch only: if the phone shows "Untrusted Developer", go to
   Settings → General → VPN & Device Management → your Apple ID → Trust,
   then run again.

### Install a build you can use without IntelliJ

A debug build only opens while connected to IntelliJ. Install a release
build instead, with the phone connected:

1. Bump the version in `pubspec.yaml` (see [Version](#version)).
2. Install:

   ```sh
   flutter devices                       # find the iPhone's id
   flutter run --release -d <iPhone id>
   ```

   Pass `-d`: if the simulator is open, Flutter picks it and fails with
   "Release mode is not supported", since the simulator only runs debug
   builds.
3. Stop `flutter run` and unplug the phone: the app opens from the home
   screen.

With a free Apple ID the app stops opening after 7 days, and the phone must
stay in Developer Mode: install it again the same way. The recipes stay on
the phone. A paid Apple Developer account ($99/year) removes the limit and
is required for TestFlight and the App Store.

### Troubleshooting

If the app crashes on the simulator at launch with `Couldn't resolve native
function ... Failed to load dynamic library 'objective_c.framework/...'`,
the build reused native libraries compiled for the iPhone. It happens after
building for the phone and then running on the simulator. Clean and run
again:

```sh
flutter clean && flutter pub get
```

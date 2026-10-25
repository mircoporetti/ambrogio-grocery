# Ambrogio Grocery

An app to plan your weekly grocery shopping starting from your recipes.

You keep your recipes in the app, choose what you want to cook during the
week, and get a single grocery list for the whole week.

Today the app runs on Android and stores everything on the device. iOS, user
accounts and a backend to share data across devices are planned for later.

## Setup

Requires Flutter (stable) and the SDK of the target platform (Android SDK
for now). Check with `flutter doctor`.

```sh
flutter pub get        # from the repo root, resolves all packages
```

All the commands below run from `apps/mobile`.

## Run

```sh
flutter emulators --launch Pixel_8   # or connect a phone with USB debugging
flutter run
```

From IntelliJ, use the `mobile` run configuration and pick the device in the
toolbar. Use a full restart, not hot reload, after changing `main.dart`, the
database or the dependencies.

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

1. Bump the version in `pubspec.yaml`. The number after `+` must increase on
   every release, or Android refuses the update:

   ```yaml
   version: 1.0.1+2
   ```

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
5. Pick the phone in IntelliJ and run.
6. First launch only: on the iPhone, Settings → General → VPN & Device
   Management → your Apple ID → Trust.

With a free Apple ID the app stops opening after 7 days: run it again from
IntelliJ to reinstall it. The recipes stay on the phone. A paid Apple
Developer account ($99/year) removes the limit and is required for
TestFlight and the App Store.

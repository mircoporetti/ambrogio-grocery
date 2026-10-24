# Ambrogio Grocery

Organize your shopping list starting from recipes.

## Layout

Dart pub workspace (monorepo), one shared lockfile at the root.

- `apps/mobile` - Flutter app (Android first)
- backend / shared packages will live alongside it and get listed in the root `pubspec.yaml`

Each feature lives in `lib/<feature>/` split into `domain/` (entities + ports),
`data/` (adapters) and `ui/` (pages + view models).

## Commands

```sh
flutter pub get                 # from the repo root
cd apps/mobile
dart run build_runner build     # regenerate drift code after changing tables
flutter test                    # acceptance tests
flutter run                     # on a connected Android device/emulator
```

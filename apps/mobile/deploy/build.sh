#!/bin/sh
set -eu
version="${1:?usage: deploy/build.sh <version> [flutter build args]}"
shift
flutter build web --release --wasm --no-web-resources-cdn --no-source-maps "$@"
rm -f build/web/flutter_service_worker.js
for file in build/web/ambrogio_service_worker.js build/web/register_service_worker.js; do
  sed -i.bak "s/__AMBROGIO_VERSION__/${version}/" "$file"
  rm "$file.bak"
done

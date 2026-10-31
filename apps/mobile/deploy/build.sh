#!/bin/sh
set -eu
version="${1:?usage: deploy/build.sh <version> [flutter build args]}"
shift
flutter build web --release --wasm --no-web-resources-cdn --no-source-maps "$@"
rm -f build/web/flutter_service_worker.js
sed -i.bak "s/__AMBROGIO_VERSION__/${version}/" build/web/ambrogio_service_worker.js
rm build/web/ambrogio_service_worker.js.bak

#!/usr/bin/env bash
# Builds the web database assets Drift needs on the web:
#   web/drift_worker.js  compiled from tool/drift_worker.dart against the
#                        drift version resolved in pubspec.lock
#   web/sqlite3.wasm     copied from the drift package itself (the SQLite
#                        WebAssembly build that ships with drift's DevTools
#                        extension)
# Re-run after upgrading drift or sqlite3:  bash tool/build_web_db_assets.sh
set -euo pipefail
cd "$(dirname "$0")/.."

dart pub get >/dev/null
dart compile js -O4 tool/drift_worker.dart -o web/drift_worker.js

drift_dir="$(dart run tool/package_dir.dart drift)"
cp "$drift_dir/extension/devtools/build/sqlite3.wasm" web/sqlite3.wasm

# Remove the compiler's by-products; only the .js worker is needed.
rm -f web/drift_worker.js.deps web/drift_worker.js.map
ls -l web/drift_worker.js web/sqlite3.wasm

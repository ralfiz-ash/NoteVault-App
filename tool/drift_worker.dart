// Entry point of the Drift web worker. Compiled to web/drift_worker.js by
// tool/build_web_db_assets.sh. Do not edit web/drift_worker.js by hand.
import 'package:drift/wasm.dart';

void main() {
  WasmDatabase.workerMainForOpen();
}

import 'package:workmanager/workmanager.dart';

import 'auto_upload_worker.dart';

/// Top-level entry point invoked by the workmanager plugin in a fresh
/// background isolate. Must be top-level (not a method) and annotated with
/// `vm:entry-point` so release-mode tree-shaking keeps it.
@pragma('vm:entry-point')
void autoUploadCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    return await runAutoUploadScan(trigger: task);
  });
}

/// Stable task names — referenced from both Dart (registerPeriodicTask)
/// and the Kotlin PhoneStateReceiver.
class AutoUploadTaskNames {
  static const periodic = 'speakr.autoUpload.periodic';

  /// Same name the Kotlin receiver enqueues from. Distinguishing call-end
  /// from periodic in logs is helpful but they run the same code.
  static const callEnded = 'speakr.autoUpload.scan';
}

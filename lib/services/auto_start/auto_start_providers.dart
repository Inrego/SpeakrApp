import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auto_start_service.dart';

final autoStartServiceProvider = Provider<AutoStartService>((ref) {
  return AutoStartService();
});

/// Reactive view of whether the Windows Run-key registration exists.
/// Invalidate after every write so the Settings toggle reflects reality.
final autoStartEnabledProvider = FutureProvider<bool>((ref) async {
  final svc = ref.watch(autoStartServiceProvider);
  return svc.isEnabled();
});

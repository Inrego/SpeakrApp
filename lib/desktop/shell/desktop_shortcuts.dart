import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

final bool _isMac = Platform.isMacOS;
final bool _isMobile = Platform.isAndroid || Platform.isIOS;

String get modLabel => _isMac ? '⌘' : 'Ctrl+';

String get returnKeyLabel => _isMac ? '↩' : 'Enter';

bool get supportsKeyboardShortcuts => !_isMobile;

SingleActivator modActivator(LogicalKeyboardKey key) =>
    SingleActivator(key, meta: _isMac, control: !_isMac);

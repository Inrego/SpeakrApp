import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

final bool _isMac = Platform.isMacOS;

String get modLabel => _isMac ? '⌘' : 'Ctrl+';

SingleActivator modActivator(LogicalKeyboardKey key) =>
    SingleActivator(key, meta: _isMac, control: !_isMac);

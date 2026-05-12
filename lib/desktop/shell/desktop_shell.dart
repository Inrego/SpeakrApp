import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import 'desktop_sidebar.dart';

/// Which top-level area the sidebar should highlight.
enum DesktopShellRoute { library }

/// Persistent left-sidebar shell used by the Library and Detail screens at
/// desktop widths. The sidebar is 240 px wide and always visible.
class DesktopShell extends StatelessWidget {
  const DesktopShell({super.key, required this.child, required this.active});

  final Widget child;
  final DesktopShellRoute active;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpeakrColors.bg,
      body: Row(
        children: [
          DesktopSidebar(active: active),
          const VerticalDivider(width: 1, color: SpeakrColors.line),
          Expanded(child: child),
        ],
      ),
    );
  }
}

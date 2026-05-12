import 'package:flutter/widgets.dart';

/// Width at which the app switches from the mobile single-column layout to
/// the desktop two-column / sidebar layout. Chosen so a half-screen Windows
/// window still gets the calmer mobile view.
const double kDesktopBreakpoint = 900.0;

/// True when the current viewport is wide enough for the desktop layout.
/// Prefer the variant that takes a [BoxConstraints] when inside a
/// [LayoutBuilder] — it avoids reading MediaQuery on every rebuild.
bool isDesktopWidth(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;

bool isDesktopConstraints(BoxConstraints c) => c.maxWidth >= kDesktopBreakpoint;

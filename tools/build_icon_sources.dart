// Renders speakr-mark-square.svg into every per-platform brand asset:
//
//  App icon sources (consumed by flutter_launcher_icons):
//   - assets/icon/icon.png             iOS + Android legacy launcher.
//                                      #FAFAF7 background, artwork at ~80%
//                                      of the canvas (10% optical inset).
//
//   - assets/icon/icon_foreground.png  Android adaptive icon foreground.
//                                      Transparent background, artwork at
//                                      ~95% of the canvas. flutter_launcher_icons
//                                      wraps this in <inset android:inset="16%"/>
//                                      in mipmap-anydpi-v26/ic_launcher.xml,
//                                      so the launcher displays the artwork at
//                                      ~65% of the 108dp adaptive-icon canvas —
//                                      just inside the 72dp safe-zone circle.
//
//  Windows app icon (written directly):
//   - windows/runner/resources/app_icon.ico
//                                      Multi-size .ico (16/24/32/48/64/128/256)
//                                      with each sub-image rendered fresh from
//                                      the primitives — not downscaled from one
//                                      master.
//
//  iOS launch screen (LaunchScreen.storyboard renders LaunchImage centered):
//   - ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage{,@2x,@3x}.png
//                                      200pt-square @1x/@2x/@3x. Transparent
//                                      background — the storyboard supplies
//                                      the cream backdrop.
//
//  Android pre-12 splash (referenced from drawable/launch_background.xml):
//   - android/app/src/main/res/drawable/launch_logo.xml
//                                      Vector drawable transcribing the same
//                                      shapes as a path-based <vector>. Density
//                                      independent.
//
// Run from `speakr_app/`:
//
//   dart run tools/build_icon_sources.dart
//   dart run flutter_launcher_icons        # iOS + Android app icons only
//
// The artwork (1 circle + 5 capsule bars) is simple enough to draw directly
// from numeric primitives, so this script does not invoke an SVG renderer —
// it transcribes the shapes from speakr-mark-square.svg. If the SVG ever
// changes, update the constants below to match.

import 'dart:io';
import 'package:image/image.dart' as img;

const _ink = (26, 26, 26); // SpeakrColors.ink  = #1A1A1A
const _cream = (250, 250, 247); // SpeakrColors.bg   = #FAFAF7

// Artwork bounding box in the SVG's 200-unit canvas (after applying the
// translate(14, 22) on the inner <g>). The bbox is wider than tall and
// slightly top-weighted in the original; we recenter it on the icon canvas.
const _bboxX = 14.0;
const _bboxY = 24.7;
const _bboxW = 172.0;
const _bboxH = 139.1;

sealed class _Shape {
  final double opacity;
  const _Shape(this.opacity);
}

class _Circle extends _Shape {
  final double cx, cy, r;
  const _Circle(this.cx, this.cy, this.r, double opacity) : super(opacity);
}

class _Capsule extends _Shape {
  // Top-left + size, with rx = h/2 (horizontal stadium shape).
  final double x, y, w, h;
  const _Capsule(this.x, this.y, this.w, this.h, double opacity)
      : super(opacity);
}

// Shape coordinates already include the SVG's translate(14, 22).
const _shapes = <_Shape>[
  _Circle(28.2, 33.2, 8.5, 1.0),
  _Capsule(48.5, 27.0, 102.5, 11.2, 1.0),
  _Capsule(14.0, 58.4, 172.0, 11.2, 0.87),
  _Capsule(14.0, 89.8, 148.0, 11.2, 0.74),
  _Capsule(14.0, 121.2, 160.0, 11.2, 0.61),
  _Capsule(14.0, 152.6, 100.0, 11.2, 0.48),
];

img.Image _renderForeground({required int size, required double contentScale}) {
  final canvas = img.Image(width: size, height: size, numChannels: 4);
  img.fill(canvas, color: img.ColorRgba8(0, 0, 0, 0));

  final maxBbox = _bboxW > _bboxH ? _bboxW : _bboxH;
  final scale = (size * contentScale) / maxBbox;
  final bboxCx = _bboxX + _bboxW / 2;
  final bboxCy = _bboxY + _bboxH / 2;
  final cCx = size / 2;
  final cCy = size / 2;

  double tx(double x) => cCx + (x - bboxCx) * scale;
  double ty(double y) => cCy + (y - bboxCy) * scale;

  for (final shape in _shapes) {
    final alpha = (shape.opacity * 255).round().clamp(0, 255);
    final color = img.ColorRgba8(_ink.$1, _ink.$2, _ink.$3, alpha);

    switch (shape) {
      case _Circle(:final cx, :final cy, :final r):
        img.fillCircle(
          canvas,
          x: tx(cx).round(),
          y: ty(cy).round(),
          radius: (r * scale).round(),
          color: color,
          antialias: true,
        );

      case _Capsule(:final x, :final y, :final w, :final h):
        // SVG uses rx = h/2 (horizontal stadium). image's fillRect renders
        // anti-aliased rounded corners when radius > 0.
        img.fillRect(
          canvas,
          x1: tx(x).round(),
          y1: ty(y).round(),
          x2: tx(x + w).round(),
          y2: ty(y + h).round(),
          color: color,
          radius: h * scale / 2,
        );
    }
  }

  return canvas;
}

img.Image _renderOnCream({required int size, required double contentScale}) {
  final fg = _renderForeground(size: size, contentScale: contentScale);
  final out = img.Image(width: size, height: size, numChannels: 4);
  img.fill(out, color: img.ColorRgba8(_cream.$1, _cream.$2, _cream.$3, 255));
  img.compositeImage(out, fg);
  return out;
}

// Sub-image sizes embedded in the Windows .ico. 16/24/32/48 cover the
// shell's small-icon slots; 64/128/256 cover the larger ones (alt-tab,
// jump lists, Settings → Apps). Each is rendered fresh, not downscaled.
const _icoSizes = <int>[16, 24, 32, 48, 64, 128, 256];

// iOS LaunchImage scales — 1x/2x/3x of a 200pt square. The storyboard's
// imageView has contentMode="center", so the image is shown at its natural
// size (size_in_pixels / scale) centered on the cream backdrop.
const _launchImageBase = 200;
const _launchImageScales = <(int, String)>[
  (1, 'LaunchImage.png'),
  (2, 'LaunchImage@2x.png'),
  (3, 'LaunchImage@3x.png'),
];

String _f(double d) {
  if (d == d.roundToDouble()) return d.toInt().toString();
  return d
      .toStringAsFixed(3)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

String _circlePath(_Circle c) {
  final left = c.cx - c.r;
  final twoR = c.r * 2;
  return 'M${_f(left)},${_f(c.cy)} '
      'a${_f(c.r)},${_f(c.r)} 0 1,0 ${_f(twoR)},0 '
      'a${_f(c.r)},${_f(c.r)} 0 1,0 ${_f(-twoR)},0 Z';
}

String _capsulePath(_Capsule c) {
  final r = c.h / 2;
  final left = c.x + r;
  final right = c.x + c.w - r;
  return 'M${_f(left)},${_f(c.y)} H${_f(right)} '
      'a${_f(r)},${_f(r)} 0 0,1 0,${_f(c.h)} '
      'H${_f(left)} '
      'a${_f(r)},${_f(r)} 0 0,1 0,${_f(-c.h)} Z';
}

String _buildVectorDrawable() {
  final buf = StringBuffer();
  buf.writeln('<?xml version="1.0" encoding="utf-8"?>');
  buf.writeln(
      '<!-- Generated by tools/build_icon_sources.dart from speakr-mark-square.svg.');
  buf.writeln('     Do not edit by hand. -->');
  buf.writeln('<vector xmlns:android="http://schemas.android.com/apk/res/android"');
  buf.writeln('    android:width="200dp"');
  buf.writeln('    android:height="200dp"');
  buf.writeln('    android:viewportWidth="200"');
  buf.writeln('    android:viewportHeight="200">');
  for (final shape in _shapes) {
    final path = switch (shape) {
      _Circle() => _circlePath(shape),
      _Capsule() => _capsulePath(shape),
    };
    buf.writeln('  <path');
    buf.writeln('      android:fillColor="#1A1A1A"');
    if (shape.opacity < 1.0) {
      buf.writeln('      android:fillAlpha="${_f(shape.opacity)}"');
    }
    buf.writeln('      android:pathData="$path" />');
  }
  buf.writeln('</vector>');
  return buf.toString();
}

void main() {
  final outDir = Directory('assets/icon');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  const size = 1024;

  final icon = _renderOnCream(size: size, contentScale: 0.80);
  File('assets/icon/icon.png').writeAsBytesSync(img.encodePng(icon));

  final fg = _renderForeground(size: size, contentScale: 0.95);
  File('assets/icon/icon_foreground.png').writeAsBytesSync(img.encodePng(fg));

  final icoFrames = [
    for (final s in _icoSizes) _renderOnCream(size: s, contentScale: 0.80),
  ];
  final icoBytes = img.IcoEncoder().encodeImages(icoFrames);
  File('windows/runner/resources/app_icon.ico').writeAsBytesSync(icoBytes);

  // iOS launch images. Transparent background (the storyboard provides cream),
  // artwork bbox max-dim filling the square so the logo reads well at splash
  // size. contentScale=1.0 means the wider artwork bbox edges touch the PNG
  // edges — there is no internal margin because the storyboard backdrop
  // already provides the breathing room around the centered imageView.
  for (final (scale, filename) in _launchImageScales) {
    final pixels = _launchImageBase * scale;
    final launch = _renderForeground(size: pixels, contentScale: 1.0);
    File('ios/Runner/Assets.xcassets/LaunchImage.imageset/$filename')
        .writeAsBytesSync(img.encodePng(launch));
  }

  // Android pre-12 splash: vector drawable used by drawable/launch_background.xml.
  File('android/app/src/main/res/drawable/launch_logo.xml')
      .writeAsStringSync(_buildVectorDrawable());

  stdout.writeln(
      'Wrote assets/icon/icon.png                                 ($size x $size, #FAFAF7 bg, 80% content)');
  stdout.writeln(
      'Wrote assets/icon/icon_foreground.png                      ($size x $size, transparent, 95% content)');
  stdout.writeln(
      'Wrote windows/runner/resources/app_icon.ico                ([${_icoSizes.join("/")}] sub-images, ${icoBytes.length} bytes)');
  for (final (scale, filename) in _launchImageScales) {
    final pixels = _launchImageBase * scale;
    stdout.writeln(
        'Wrote ios/Runner/Assets.xcassets/LaunchImage.imageset/$filename'
        '${' ' * (16 - filename.length)}'
        '($pixels x $pixels @${scale}x)');
  }
  stdout.writeln(
      'Wrote android/app/src/main/res/drawable/launch_logo.xml    (vector, 200dp x 200dp)');
}

// Renders the Google Play store graphics that are not screenshots:
//
//   - docs/play-store/assets/feature-graphic-1024x500.png
//       1024×500, RGB (**no alpha** — Play rejects a feature graphic with an
//       alpha channel). The brand mark centered on the #FAFAF7 cream.
//       Deliberately wordmark-free: Play overlays the app title itself in
//       several placements, and the calm-minimal direction reads better
//       without competing text.
//
//   - docs/play-store/assets/icon-512.png
//       512×512 RGBA, downscaled from assets/icon/icon.png (1024×1024).
//
// The artwork primitives are transcribed from speakr-mark-square.svg, the same
// way tools/build_icon_sources.dart does it — if the SVG changes, update both.
//
// Run from the repo root:
//
//   dart run tools/build_store_graphics.dart

import 'dart:io';

import 'package:image/image.dart' as img;

const _ink = (26, 26, 26); // SpeakrColors.ink   = #1A1A1A
const _cream = (250, 250, 247); // SpeakrColors.bg    = #FAFAF7

// Artwork bounding box in the SVG's 200-unit canvas, after the inner <g>'s
// translate(14, 22) has been folded into the shape coordinates below.
const _bboxX = 14.0;
const _bboxY = 24.7;
const _bboxW = 172.0;
const _bboxH = 139.1;

sealed class _Shape {
  const _Shape(this.opacity);
  final double opacity;
}

class _Circle extends _Shape {
  const _Circle(this.cx, this.cy, this.r, double opacity) : super(opacity);
  final double cx, cy, r;
}

class _Capsule extends _Shape {
  const _Capsule(this.x, this.y, this.w, this.h, double opacity)
      : super(opacity);
  final double x, y, w, h;
}

const _shapes = <_Shape>[
  _Circle(28.2, 33.2, 8.5, 1.0),
  _Capsule(48.5, 27.0, 102.5, 11.2, 1.0),
  _Capsule(14.0, 58.4, 172.0, 11.2, 0.87),
  _Capsule(14.0, 89.8, 148.0, 11.2, 0.74),
  _Capsule(14.0, 121.2, 160.0, 11.2, 0.61),
  _Capsule(14.0, 152.6, 100.0, 11.2, 0.48),
];

/// Draws the mark into [canvas] with its bounding box mapped onto the
/// rectangle (left, top, width, height).
void _drawMark(
  img.Image canvas, {
  required double left,
  required double top,
  required double width,
  required double height,
}) {
  final sx = width / _bboxW;
  final sy = height / _bboxH;
  double tx(double x) => left + (x - _bboxX) * sx;
  double ty(double y) => top + (y - _bboxY) * sy;

  for (final shape in _shapes) {
    final alpha = (shape.opacity * 255).round().clamp(0, 255);
    final color = img.ColorRgba8(_ink.$1, _ink.$2, _ink.$3, alpha);
    switch (shape) {
      case _Circle(:final cx, :final cy, :final r):
        img.fillCircle(
          canvas,
          x: tx(cx).round(),
          y: ty(cy).round(),
          radius: (r * sx).round(),
          color: color,
          antialias: true,
        );
      case _Capsule(:final x, :final y, :final w, :final h):
        img.fillRect(
          canvas,
          x1: tx(x).round(),
          y1: ty(y).round(),
          x2: tx(x + w).round(),
          y2: ty(y + h).round(),
          color: color,
          radius: h * sy / 2,
        );
    }
  }
}

img.Image _buildFeatureGraphic() {
  const w = 1024;
  const h = 500;

  // The mark is composited from an RGBA layer so its per-shape opacities
  // blend against the cream rather than being written straight into an
  // alpha-less canvas.
  final layer = img.Image(width: w, height: h, numChannels: 4);
  img.fill(layer, color: img.ColorRgba8(0, 0, 0, 0));

  // Sized and centered so the lockup reads as a logo at the ~1024x500 sizes
  // Play renders the graphic at, with the calm-minimal direction's generous
  // margins intact.
  const markH = 284.0;
  final markW = markH * _bboxW / _bboxH;
  _drawMark(
    layer,
    left: (w - markW) / 2,
    top: (h - markH) / 2,
    width: markW,
    height: markH,
  );

  // numChannels: 3 → the PNG encoder writes RGB with no alpha channel.
  final out = img.Image(width: w, height: h, numChannels: 3);
  img.fill(out, color: img.ColorRgb8(_cream.$1, _cream.$2, _cream.$3));
  img.compositeImage(out, layer);
  return out;
}

void main() {
  final outDir = Directory('docs/play-store/assets');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  final feature = _buildFeatureGraphic();
  final featurePath = '${outDir.path}/feature-graphic-1024x500.png';
  File(featurePath).writeAsBytesSync(img.encodePng(feature));
  stdout.writeln(
    'wrote $featurePath  ${feature.width}x${feature.height} '
    'channels=${feature.numChannels}',
  );

  final source = img.decodePng(File('assets/icon/icon.png').readAsBytesSync());
  if (source == null) {
    stderr.writeln('could not read assets/icon/icon.png');
    exitCode = 1;
    return;
  }
  final icon = img.copyResize(
    source,
    width: 512,
    height: 512,
    interpolation: img.Interpolation.cubic,
  );
  final iconPath = '${outDir.path}/icon-512.png';
  File(iconPath).writeAsBytesSync(img.encodePng(icon));
  stdout.writeln(
    'wrote $iconPath  ${icon.width}x${icon.height} '
    'channels=${icon.numChannels}',
  );
}

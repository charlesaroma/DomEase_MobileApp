// ─── DomEase Logo ─────────────────────────────────────────────────
// The house in bloom, painted from the approved artwork's paths
// (brand_paths.dart), so it is sharp at every size and can take any of the
// approved colourways. Never rebuild the logo from a Text widget.
import 'package:flutter/widgets.dart';
import 'package:path_drawing/path_drawing.dart';

import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/ui/brand/brand_paths.dart';

/// The approved colourways (docs/05-design-system.md, Logo).
enum LogoTone {
  /// Full colour on paper or white: clay house, sage plant, clay tulip.
  primary(AppColors.clay, AppColors.sage, AppColors.clay600, AppColors.ink, AppColors.ink2),

  /// Full colour on Clay 900 or Night.
  reversed(AppColors.clay200, AppColors.sage400, AppColors.clay400, AppColors.white, AppColors.clay200),

  /// One colour clay, on light grounds.
  clay(AppColors.clay, AppColors.clay, AppColors.clay, AppColors.clay900, AppColors.clay800),

  /// One colour white, on Clay 700 or photos.
  white(AppColors.white, AppColors.white, AppColors.white, AppColors.white, AppColors.white);

  const LogoTone(this.house, this.leaf, this.flower, this.word, this.tag);
  final Color house;
  final Color leaf;
  final Color flower;
  final Color word;
  final Color tag;

  Color of(BrandPart part) => switch (part) {
        BrandPart.house => house,
        BrandPart.leaf => leaf,
        BrandPart.flower => flower,
        BrandPart.word => word,
        BrandPart.tag => tag,
      };
}

/// Which lockup to draw.
enum LogoLayout { stacked, stackedNoTagline, horizontal, horizontalNoTagline, mark, markIcon, wordmark }

/// The logo at a given width (or height); the other side follows the art.
class DomEaseLogo extends StatelessWidget {
  const DomEaseLogo({
    super.key,
    this.layout = LogoLayout.stacked,
    this.tone = LogoTone.primary,
    this.width,
    this.height,
    this.semanticLabel = 'DomEase',
  }) : assert(width != null || height != null, 'Give the logo a width or a height');

  final LogoLayout layout;
  final LogoTone tone;
  final double? width;
  final double? height;
  final String semanticLabel;

  BrandArt get art => switch (layout) {
        LogoLayout.stacked => BrandPaths.stacked,
        LogoLayout.stackedNoTagline => BrandPaths.stackedNoTagline,
        LogoLayout.horizontal => BrandPaths.horizontal,
        LogoLayout.horizontalNoTagline => BrandPaths.horizontalNoTagline,
        LogoLayout.mark => BrandPaths.mark,
        LogoLayout.markIcon => BrandPaths.markIcon,
        LogoLayout.wordmark => BrandPaths.wordmark,
      };

  @override
  Widget build(BuildContext context) {
    final a = art;
    final w = width ?? height! * a.width / a.height;
    final h = height ?? width! * a.height / a.width;
    return Semantics(
      label: semanticLabel,
      image: true,
      child: SizedBox(
        width: w,
        height: h,
        child: CustomPaint(painter: _LogoPainter(a, tone)),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  _LogoPainter(this.art, this.tone);

  final BrandArt art;
  final LogoTone tone;

  /// Parsed once per path string for the life of the app.
  static final Map<String, Path> _cache = {};

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / art.width, size.height / art.height);
    for (final layer in art.layers) {
      final path = _cache.putIfAbsent(layer.d, () => parseSvgPathData(layer.d));
      final paint = Paint()
        ..color = tone.of(layer.part)
        ..isAntiAlias = true;
      if (layer.stroke > 0) {
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = layer.stroke
          ..strokeCap = layer.round ? StrokeCap.round : StrokeCap.butt
          ..strokeJoin = layer.round ? StrokeJoin.round : StrokeJoin.miter;
      }
      canvas
        ..save()
        ..translate(layer.dx, layer.dy)
        ..scale(layer.scale);
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.art != art || old.tone != tone;
}

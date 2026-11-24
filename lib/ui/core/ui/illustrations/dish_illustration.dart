// ─── Dish Illustration ────────────────────────────────────────────
// A dish drawn from dish_paths.dart: sharp at any size, the same style on
// every screen. Use it wherever a dish needs a picture; never an emoji.
import 'package:flutter/widgets.dart';
import 'package:path_drawing/path_drawing.dart';

import 'package:domease/ui/core/ui/illustrations/dish_paths.dart';

export 'package:domease/ui/core/ui/illustrations/dish_paths.dart' show Dish;

class DishIllustration extends StatelessWidget {
  const DishIllustration(this.dish, {super.key, this.size = 56, this.semanticLabel});

  final Dish dish;

  /// Width and height; the drawing is square.
  final double size;

  /// Read out by screen readers. Leave null when a label sits beside it.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final art = SizedBox.square(dimension: size, child: CustomPaint(painter: _DishPainter(dish)));
    return semanticLabel == null ? ExcludeSemantics(child: art) : Semantics(label: semanticLabel, image: true, child: art);
  }
}

class _DishPainter extends CustomPainter {
  _DishPainter(this.dish);

  final Dish dish;

  /// Parsed once per path string for the life of the app.
  static final Map<String, Path> _cache = {};

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / DishPaths.box;
    canvas
      ..translate((size.width - DishPaths.box * s) / 2, (size.height - DishPaths.box * s) / 2)
      ..scale(s);
    for (final layer in DishPaths.of(dish)) {
      final path = _cache.putIfAbsent(layer.d, () => parseSvgPathData(layer.d));
      final paint = Paint()
        ..isAntiAlias = true
        ..color = layer.color;
      if (layer.stroke > 0) {
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = layer.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_DishPainter old) => old.dish != dish;
}

// ─── Animated Logo ────────────────────────────────────────────────
// The house in bloom, drawn line by line from the approved artwork
// (brand_paths.dart), with the same story and timing as the website
// (DomEase web repo, src/components/brand/logoMotion.js):
//
//   draw     the house goes up, the plant grows from the ground, the leaves
//            open, the tulip blooms, then the name and tagline rise in (once)
//   loading  the same drawing at double speed, a pause, a fade, on a loop
//
// When the phone asks for reduced motion the finished logo shows at once.
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:path_drawing/path_drawing.dart';

import 'package:domease/ui/core/ui/brand/brand_paths.dart';
import 'package:domease/ui/core/ui/brand/domease_logo.dart';

enum LogoMotion { draw, loading }

/// The mark's lines in drawing order. Brand paths list the mark's 18 stroked
/// lines first in every lockup; this names what each one is.
const _parts = [
  'house', 'house', 'house', 'stem', 'stem', 'stem', //
  'leaf', 'vein', 'leaf', 'vein', 'leaf', 'vein', 'leaf', 'leaf', 'vein', //
  'flower', 'flower', 'flower',
];

/// start, step between lines, duration (seconds), as on the website.
const _timing = {
  'house': (0.0, 0.22, 0.7),
  'stem': (0.55, 0.12, 0.8),
  'leaf': (0.95, 0.12, 0.6),
  'vein': (1.25, 0.12, 0.35),
  'flower': (1.7, 0.1, 0.55),
};

/// When mark line [i] starts and how long it takes, in seconds.
(double, double) _when(int i) {
  final part = _parts[i];
  final (start, step, duration) = _timing[part]!;
  final nth = _parts.take(i).where((p) => p == part).length;
  // The side shoot waits until the main stem has grown past it.
  final extra = part == 'stem' && nth == 1 ? 0.3 : 0.0;
  return (start + step * nth + extra, duration);
}

final List<(double, double)> _schedule = [for (var i = 0; i < _parts.length; i++) _when(i)];

const _wordAt = 2.05, _tagAt = 2.35, _riseFor = 0.7, _drawTotal = 3.05;
const _loopSeconds = 2.6;

class AnimatedDomEaseLogo extends StatefulWidget {
  const AnimatedDomEaseLogo({
    super.key,
    this.layout = LogoLayout.stacked,
    this.tone = LogoTone.primary,
    this.motion = LogoMotion.draw,
    this.width,
    this.height,
    this.speed = 1,
    this.semanticLabel = 'DomEase',
    this.onDrawn,
  }) : assert(width != null || height != null, 'Give the logo a width or a height');

  final LogoLayout layout;
  final LogoTone tone;
  final LogoMotion motion;
  final double? width;
  final double? height;

  /// 1 is the website's pace; the splash uses a little faster.
  final double speed;
  final String semanticLabel;

  /// Called once the drawing has finished (draw only).
  final VoidCallback? onDrawn;

  @override
  State<AnimatedDomEaseLogo> createState() => _AnimatedDomEaseLogoState();
}

class _AnimatedDomEaseLogoState extends State<AnimatedDomEaseLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(vsync: this);
  bool _still = false;
  bool _told = false;

  void _drawn() {
    if (_told) return;
    _told = true;
    widget.onDrawn?.call();
  }

  double get _seconds => widget.motion == LogoMotion.loading ? _loopSeconds : _drawTotal / widget.speed;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _clock.duration = Duration(milliseconds: (_seconds * 1000).round());
    if (_still) {
      _clock.stop();
      _clock.value = 1;
      // Never call back into a parent while it is building.
      WidgetsBinding.instance.addPostFrameCallback((_) => _drawn());
    } else if (!_clock.isAnimating && _clock.value == 0) {
      if (widget.motion == LogoMotion.loading) {
        _clock.repeat();
      } else {
        _clock.forward().whenComplete(_drawn);
      }
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final art = brandArtFor(widget.layout);
    final w = widget.width ?? widget.height! * art.width / art.height;
    final h = widget.height ?? widget.width! * art.height / art.width;
    return Semantics(
      label: widget.semanticLabel,
      image: true,
      child: SizedBox(
        width: w,
        height: h,
        child: AnimatedBuilder(
          animation: _clock,
          builder: (context, _) => CustomPaint(
            painter: _MotionPainter(
              art: art,
              tone: widget.tone,
              loading: widget.motion == LogoMotion.loading && !_still,
              // Seconds into the story, at the website's pace.
              t: _still ? 99 : _clock.value * (widget.motion == LogoMotion.loading ? _loopSeconds : _drawTotal),
            ),
          ),
        ),
      ),
    );
  }
}

class _MotionPainter extends CustomPainter {
  _MotionPainter({required this.art, required this.tone, required this.loading, required this.t});

  final BrandArt art;
  final LogoTone tone;
  final bool loading;
  final double t;

  static final Map<String, Path> _cache = {};

  static double _ease(double x) => x < 0.5 ? 4 * x * x * x : 1 - math.pow(-2 * x + 2, 3) / 2;
  double _progress(double start, double duration) => ((t - start) / duration).clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width / art.width, size.height / art.height);
    canvas
      ..translate((size.width - art.width * s) / 2, (size.height - art.height * s) / 2)
      ..scale(s);
    // The loop draws at double speed, holds, then fades.
    final factor = loading ? 0.5 : 1.0;
    final fade = loading ? (1 - ((t / _loopSeconds - 0.82) / 0.18).clamp(0.0, 1.0)) : 1.0;

    var line = 0;
    for (final layer in art.layers) {
      final path = _cache.putIfAbsent(layer.d, () => parseSvgPathData(layer.d));
      final paint = Paint()..isAntiAlias = true;
      canvas
        ..save()
        ..translate(layer.dx, layer.dy)
        ..scale(layer.scale);

      if (layer.stroke > 0 && line < _schedule.length) {
        final (start, duration) = _schedule[line];
        final part = _parts[line];
        line++;
        final p = _ease(_progress(start * factor, duration * factor));
        if (p > 0) {
          paint
            ..color = tone.of(layer.part).withValues(alpha: fade)
            ..style = PaintingStyle.stroke
            ..strokeWidth = layer.stroke
            ..strokeCap = layer.round ? StrokeCap.round : StrokeCap.butt
            ..strokeJoin = layer.round ? StrokeJoin.round : StrokeJoin.miter;
          // The tulip opens a little as it is drawn.
          if (part == 'flower' && !loading) {
            final bloom = Curves.easeOutBack.transform(_progress(1.75, 0.9));
            canvas
              ..translate(668, 238)
              ..rotate((1 - bloom) * -6 * math.pi / 180)
              ..scale(0.82 + 0.18 * bloom)
              ..translate(-668, -238);
          }
          canvas.drawPath(p >= 1 ? path : _partOf(path, p), paint);
        }
      } else if (layer.stroke == 0) {
        // The name and the tagline rise in after the mark.
        final at = layer.part == BrandPart.tag ? _tagAt : _wordAt;
        final r = loading ? 1.0 : Curves.easeInOutCubic.transform(_progress(at, _riseFor));
        if (r > 0) {
          paint.color = tone.of(layer.part).withValues(alpha: r * fade);
          canvas
            ..translate(0, (1 - r) * 14 / layer.scale)
            ..drawPath(path, paint);
        }
      }
      canvas.restore();
    }
  }

  /// The first [fraction] of a path, across all its contours.
  static Path _partOf(Path path, double fraction) {
    final metrics = path.computeMetrics().toList();
    final total = metrics.fold<double>(0, (sum, m) => sum + m.length);
    var left = total * fraction;
    final out = Path();
    for (final m in metrics) {
      if (left <= 0) break;
      out.addPath(m.extractPath(0, math.min(left, m.length)), Offset.zero);
      left -= m.length;
    }
    return out;
  }

  @override
  bool shouldRepaint(_MotionPainter old) => old.t != t || old.tone != tone || old.art != art;
}

/// The loading state at a size: the mark drawing itself, on a loop.
class LogoLoader extends StatelessWidget {
  const LogoLoader({super.key, this.size = 56, this.tone = LogoTone.primary});

  final double size;
  final LogoTone tone;

  @override
  Widget build(BuildContext context) => AnimatedDomEaseLogo(
        layout: LogoLayout.mark,
        motion: LogoMotion.loading,
        tone: tone,
        width: size,
        semanticLabel: 'Loading',
      );
}

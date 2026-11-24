from dishes import DISHES
def argb(hexc, o):
    a=round(o*255); return f"0x{a:02X}{hexc[1:].upper()}"
lines=['''// ─── Dish Paths (generated) ───────────────────────────────────────
// Spot illustrations of the dishes DomEase plans, drawn in a 96 x 96 box:
// flat shapes, light from the top left, a soft shadow, the brand's warm range.
// Do not edit by hand; regenerate from the illustration source.
import 'dart:ui' show Color;

/// One shape. [stroke] 0 means filled; otherwise a round ended line that wide.
class DishLayer {
  const DishLayer(this.d, this.color, {this.stroke = 0});
  final String d;
  final Color color;
  final double stroke;
}

/// The dishes that have a drawing.
enum Dish { groundnutStew, matokeKatogo, rolex, tilapia, beefPilau, mandazi }

abstract final class DishPaths {
  static const double box = 96;

  static List<DishLayer> of(Dish dish) => switch (dish) {''']
for k in DISHES: lines.append(f"        Dish.{k} => {k},")
lines.append("      };\n")
for k,f in DISHES.items():
    lines.append(f"  static const {k} = [")
    for l in f():
        if l[0]=='F': lines.append(f"    DishLayer('{l[1].strip()}', Color({argb(l[2],l[3])})),")
        else: lines.append(f"    DishLayer('{l[1].strip()}', Color({argb(l[2],l[4])}), stroke: {l[3]:g}),")
    lines.append("  ];\n")
lines[-1]=lines[-1].rstrip('\n')
lines.append("}\n")
open('dish_paths.dart','w').write('\n'.join(lines))

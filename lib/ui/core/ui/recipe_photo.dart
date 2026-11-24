// ─── Recipe Photo ─────────────────────────────────────────────────
// A dish's cover photo, uploaded in the admin and kept on the phone after the
// first load (cached_network_image), so a week of meals costs little data.
// With no photo yet, or offline, each meal type gets its own tint and glyph,
// never a broken image or an empty grey box.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:domease/domain/models/recipe.dart';
import 'package:domease/ui/core/themes/tokens.dart';

class RecipePhoto extends StatelessWidget {
  const RecipePhoto({
    super.key,
    required this.recipe,
    this.aspectRatio = 4 / 3,
    this.radius = BorderRadius.zero,
    this.iconSize = 40,
  });

  final Recipe recipe;
  final double aspectRatio;
  final BorderRadius radius;
  final double iconSize;

  static const _look = {
    MealType.breakfast: (
      Icons.free_breakfast_outlined,
      AppColors.amber200,
      AppColors.amber800,
    ),
    MealType.lunch: (
      Icons.rice_bowl_outlined,
      AppColors.sage100,
      AppColors.sage800,
    ),
    MealType.dinner: (
      Icons.soup_kitchen_outlined,
      AppColors.clay100,
      AppColors.clay800,
    ),
    MealType.snack: (
      Icons.local_cafe_outlined,
      AppColors.sage200,
      AppColors.sage800,
    ),
    MealType.pastry: (
      Icons.bakery_dining_outlined,
      AppColors.clay200,
      AppColors.clay900,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final (icon, tint, ink) = _look[recipe.mealType]!;
    final placeholder = ColoredBox(
      color: tint,
      child: Center(
        child: Icon(icon, size: iconSize, color: ink),
      ),
    );
    final url = recipe.photo?.url;
    return ClipRRect(
      borderRadius: radius,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: url == null
            ? Semantics(
                label: '${recipe.name}, no photo yet',
                child: placeholder,
              )
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 200),
                placeholder: (_, _) => ColoredBox(color: tint),
                errorWidget: (_, _, _) => placeholder,
                imageBuilder: (_, image) => Semantics(
                  image: true,
                  label: recipe.photo!.alt.isEmpty
                      ? recipe.name
                      : recipe.photo!.alt,
                  child: Image(image: image, fit: BoxFit.cover),
                ),
              ),
      ),
    );
  }
}

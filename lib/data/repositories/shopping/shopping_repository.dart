// ─── Shopping Repository ──────────────────────────────────────────
import 'package:domease/domain/models/shopping.dart';

/// Market prices, and what the household added or ticked by hand. The list
/// itself is worked out from these (domain/use_cases/build_shopping_list.dart).
abstract interface class ShoppingRepository {
  Future<List<MarketPrice>> prices();
  Future<ShopState> state();
  Future<void> saveState(ShopState state);
}

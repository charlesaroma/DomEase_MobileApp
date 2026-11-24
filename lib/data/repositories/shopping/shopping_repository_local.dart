// ─── Shopping Repository (demo) ───────────────────────────────────
import 'package:domease/data/model/json.dart';
import 'package:domease/data/model/shopping_json.dart';
import 'package:domease/data/repositories/shopping/shopping_repository.dart';
import 'package:domease/data/services/demo_assets.dart';
import 'package:domease/data/services/prefs_store.dart';
import 'package:domease/domain/models/shopping.dart';

class ShoppingRepositoryLocal implements ShoppingRepository {
  ShoppingRepositoryLocal(this._store);

  final PrefsStore _store;

  @override
  Future<List<MarketPrice>> prices() async => [for (final j in await loadDemoList('prices')) priceFromJson(j)];

  @override
  Future<ShopState> state() async {
    final json = await _store.read('shop');
    return json == null ? const ShopState() : shopStateFromJson(json as Json);
  }

  @override
  Future<void> saveState(ShopState state) => _store.write('shop', shopStateToJson(state));
}

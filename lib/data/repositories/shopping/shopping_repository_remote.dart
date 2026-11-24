// ─── Shopping Repository (API) ────────────────────────────────────
import 'package:domease/data/model/json.dart';
import 'package:domease/data/model/shopping_json.dart';
import 'package:domease/data/repositories/shopping/shopping_repository.dart';
import 'package:domease/data/services/api/api_client.dart';
import 'package:domease/domain/models/shopping.dart';

class ShoppingRepositoryRemote implements ShoppingRepository {
  ShoppingRepositoryRemote(this._api);

  final ApiClient _api;

  @override
  Future<List<MarketPrice>> prices() async => [for (final j in await _api.get('/prices') as List) priceFromJson(j as Json)];

  @override
  Future<ShopState> state() async => shopStateFromJson(await _api.get('/households/me/shopping') as Json);

  @override
  Future<void> saveState(ShopState state) => _api.put('/households/me/shopping', shopStateToJson(state));
}

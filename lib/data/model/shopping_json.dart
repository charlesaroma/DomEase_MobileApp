// ─── Shopping JSON ────────────────────────────────────────────────
import 'package:domease/data/model/json.dart';
import 'package:domease/domain/models/shopping.dart';

MarketPrice priceFromJson(Json j) => MarketPrice(
      name: j['name'] as String,
      pack: (j['pack'] as String?) ?? '',
      price: toIntOrNull(j['price']) ?? 0,
      category: (j['category'] as String?) ?? 'Other',
    );

ShopState shopStateFromJson(Json j) => ShopState(
      checked: strings(j['checked']).toSet(),
      manual: [
        for (final m in (j['manual'] as List?) ?? const [])
          ShoppingItem(
            id: (m as Json)['id'] as String,
            name: m['name'] as String,
            category: (m['category'] as String?) ?? 'Added by hand',
            source: ItemSource.manual,
            quantity: m['quantity'] as String?,
            price: toIntOrNull(m['price']),
          ),
      ],
    );

Json shopStateToJson(ShopState s) => {
      'checked': s.checked.toList(),
      'manual': [
        for (final m in s.manual) {'id': m.id, 'name': m.name, 'category': m.category, 'quantity': m.quantity, 'price': m.price},
      ],
    };

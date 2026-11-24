// ─── Shopping ─────────────────────────────────────────────────────

enum ItemSource { meal, zone, manual }

/// One line on the combined list (FR-SL-1).
class ShoppingItem {
  const ShoppingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.source,
    this.quantity,
    this.price,
    this.low = false,
    this.checked = false,
  });

  final String id;
  final String name;
  final String category;
  final ItemSource source;

  /// "1 kg", "bunch": the market pack.
  final String? quantity;

  /// Estimated price in UGX at the market, when known.
  final int? price;
  final bool low;
  final bool checked;

  ShoppingItem copyWith({bool? checked}) => ShoppingItem(
        id: id,
        name: name,
        category: category,
        source: source,
        quantity: quantity,
        price: price,
        low: low,
        checked: checked ?? this.checked,
      );
}

/// What the household changed by hand: items added and items ticked.
class ShopState {
  const ShopState({this.manual = const [], this.checked = const {}});

  final List<ShoppingItem> manual;
  final Set<String> checked;

  ShopState copyWith({List<ShoppingItem>? manual, Set<String>? checked}) =>
      ShopState(manual: manual ?? this.manual, checked: checked ?? this.checked);
}

/// A market price: what one pack costs, and where it sits on the list.
class MarketPrice {
  const MarketPrice({required this.name, required this.pack, required this.price, required this.category});

  final String name;
  final String pack;
  final int price;
  final String category;
}

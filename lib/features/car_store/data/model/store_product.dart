class StoreProduct {
  int? amount;
  String? barcode;
  double? price;

  StoreProduct({
    this.amount,
    this.barcode,
    this.price,
  });

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'barcode': barcode,
      'price': price,
    };
  }

  // fromJson factory constructor
  factory StoreProduct.fromJson(Map<String, dynamic> json) {
    return StoreProduct(
      amount: json['amount'] as int?,
      barcode: json['barcode'] as String?,
      price: (json['price'] as num?)?.toDouble(),
    );
  }

  // copyWith method
  StoreProduct copyWith({
    int? amount,
    String? barcode,
    double? price,
  }) {
    return StoreProduct(
      amount: amount ?? this.amount,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
    );
  }
}

class StoreProducts {
  final List<StoreProduct> storeProduct;

  StoreProducts({required this.storeProduct});

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'storeProduct': storeProduct.map((e) => e.toJson()).toList(),
    };
  }

  // fromJson factory constructor
  factory StoreProducts.fromJson(Map<String, dynamic> json) {
    return StoreProducts(
      storeProduct: (json['storeProduct'] ?? []).map((e) => StoreProduct.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  // copyWith method
  StoreProducts copyWith({
    List<StoreProduct>? storeProduct,
  }) {
    return StoreProducts(
      storeProduct: storeProduct ?? this.storeProduct,
    );
  }
}

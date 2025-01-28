import 'package:ba3_bs/features/car_store/data/model/store_product.dart';

class StoreCartModel {
  String? id;
  String? sellerName;
  StoreProducts? storeProducts;

  StoreCartModel({
    this.id,
    this.sellerName,
    this.storeProducts,
  });

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerName': sellerName,
      'storeProducts': storeProducts?.toJson(),
    };
  }

  // fromJson factory constructor
  factory StoreCartModel.fromJson(Map<String, dynamic> json) {
    return StoreCartModel(
      id: json['id'] as String?,
      sellerName: json['sellerName'] as String?,
      storeProducts: json['storeProducts'] != null
          ? StoreProducts.fromJson(json['storeProducts'] as Map<String, dynamic>)
          : null,
    );
  }

  // copyWith method
  StoreCartModel copyWith({
    String? id,
    String? sellerName,
    StoreProducts? storeProducts,
  }) {
    return StoreCartModel(
      id: id ?? this.id,
      sellerName: sellerName ?? this.sellerName,
      storeProducts: storeProducts ?? this.storeProducts,
    );
  }
}


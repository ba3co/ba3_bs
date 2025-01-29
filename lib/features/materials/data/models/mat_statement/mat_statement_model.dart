import 'package:pluto_grid/pluto_grid.dart';

import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/widgets/pluto_auto_id_column.dart';
import '../../../../pluto/data/models/pluto_adaptable.dart';

class MatStatementModel implements PlutoAdaptable {
  final MatOrigin? matOrigin;

  final int? quantity;

  final double? price;
  final DateTime? date;
  final String? note;
  final String? matId;
  final String? docId;

  MatStatementModel({
    this.matOrigin,
    this.quantity,
    this.note,
    this.date,
    this.price,
    this.matId,
    this.docId,
  });

  /// Creates an instance from a JSON object.
  factory MatStatementModel.fromJson(Map<String, dynamic> json) {
    return MatStatementModel(
      matOrigin: MatOrigin.fromJson(json['matOriginType']),
      quantity: (json['quantity'] as num?)?.toInt(),
      note: json['note'] as String?,
      matId: json['matId'],
      docId: json['docId'],
      date: DateTime.tryParse(json['date'] as String? ?? ''),
      price: (json['price'] as num?)?.toDouble(),
    );
  }

  /// Converts the instance to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'matOriginType': matOrigin?.toJson(),
      'quantity': quantity,
      'note': note,
      'matId': matId,
      'docId': docId,
      'date': date?.toIso8601String(),
      'price': price,
    };
  }

  /// Creates a new instance with modified fields.
  MatStatementModel copyWith({
    final MatOrigin? matOrigin,
    final int? quantity,
    final String? note,
    final String? originId,
    final double? price,
    final DateTime? date,
    final String? docId,
    final String? matId,
  }) {
    return MatStatementModel(
      matOrigin: matOrigin ?? this.matOrigin,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
      date: date ?? this.date,
      price: price ?? this.price,
      matId: matId ?? this.matId,
      docId: docId ?? this.docId,
    );
  }

  @override
  String toString() {
    return 'MatStatementItemModel(docId: $docId, matId: $matId, amount: $quantity, matOriginType: ${matOrigin?.toJson()}, price: $price'
        ', date: $date, note: $note)';
  }

  @override
  Map<PlutoColumn, dynamic> toPlutoGridFormat([void _]) {
    return {
      PlutoColumn(hide: true, title: 'originId', field: 'originId', type: PlutoColumnType.text()):
          matOrigin?.originId ?? '',
      createAutoIdColumn(): '',
      PlutoColumn(title: 'التاريخ', field: 'التاريخ', type: PlutoColumnType.date()): date,
      PlutoColumn(title: 'البيان', field: 'البيان', type: PlutoColumnType.text()): note,
    };
  }
}

class MatOrigin {
  /// Unique identifier for the bond entry, which is the same as the origin ID (e.g., billId).
  final String? originId;

  /// Refers to the origin entity type id of the bond entry (e.g., billTypeId for bills).
  final String? originTypeId;

  /// Refers to the type of the bond entry (bond, bill, cheque).
  final MatOriginType? originType;

  MatOrigin({
    this.originId,
    this.originTypeId,
    this.originType,
  });

  factory MatOrigin.fromJson(Map<String, dynamic> json) {
    return MatOrigin(
      originId: json['originId'] as String?,
      originTypeId: json['originTypeId'] as String?,
      originType: MatOriginType.byLabel(json['originType']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originId': originId,
      'originTypeId': originTypeId,
      'originType': originType?.label,
    };
  }

  MatOrigin copyWith({
    String? originId,
    String? originTypeId,
    MatOriginType? originType,
  }) {
    return MatOrigin(
      originId: originId ?? this.originId,
      originTypeId: originTypeId ?? this.originTypeId,
      originType: originType ?? this.originType,
    );
  }
}

import 'package:pluto_grid/pluto_grid.dart';

import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/widgets/pluto_auto_id_column.dart';
import '../../../../pluto/data/models/pluto_adaptable.dart';

class MatStatementItemModel implements PlutoAdaptable {
  final MatOrigin? matOrigin;

  final double? amount;

  final double? price;
  final String? date;
  final String? note;
  final String? id;

  MatStatementItemModel({
    this.matOrigin,
    this.amount,
    this.note,
    this.date,
    this.price,
    this.id,
  });

  /// Creates an instance from a JSON object.
  factory MatStatementItemModel.fromJson(Map<String, dynamic> json) {
    return MatStatementItemModel(

      matOrigin: MatOrigin.fromJson(json['matOriginType']),
      amount: (json['amount'] as num?)?.toDouble(),
      note: json['note'] as String?,
      id: json['docId'] as String?,
      date: json['date'] as String?,
      price: (json['price'] as num?)?.toDouble(),
    );
  }

  /// Converts the instance to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'matOriginType': matOrigin?.toJson(),
      'amount': amount,
      'note': note,
      'docId': id,
      'date': date,
      'price': price,
    };
  }

  /// Creates a new instance with modified fields.
  MatStatementItemModel copyWith({
    final MatOrigin? matOrigin,
    final double? amount,
    final String? note,
    final String? originId,
    final double? price,
    final String? date,
    final String? id,
  }) {
    return MatStatementItemModel(
      matOrigin: matOrigin ?? this.matOrigin,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      date: date ?? this.date,
      price: price ?? this.price,
      id: id ?? this.id,
    );
  }

  @override
  String toString() {
    return 'MatStatementItemModel(docId: $id, amount: $amount, matOriginType: ${matOrigin?.toJson()}, price: $price'
        ', date: $date, note: $note)';
  }

  @override
  Map<PlutoColumn, dynamic> toPlutoGridFormat([void _]) {
    return {
      PlutoColumn(hide: true, title: 'originId', field: 'originId', type: PlutoColumnType.text()): matOrigin?.originId ?? '',
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
      originId: json['docId'] as String?,
      originTypeId: json['originTypeId'] as String?,
      originType: MatOriginType.byLabel(json['originType']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'docId': originId,
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

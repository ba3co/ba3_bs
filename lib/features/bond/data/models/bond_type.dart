import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import '../../../../core/helper/enums/enums.dart';

@HiveType(typeId: 0)
// ignore: must_be_immutable
class BondTypeModel extends HiveObject with EquatableMixin {
  @HiveField(1)
  final String label;

  @HiveField(2)
  final String value;

  @HiveField(3)
  final String typeGuide;

  @HiveField(4)
  final int from;

  @HiveField(5)
  final int to;

  @HiveField(6)
  final int taxType;

  @HiveField(7)
  final String color;

  @HiveField(8)
  final BondType type;

  BondTypeModel({
    required this.label,
    required this.value,
    required this.typeGuide,
    required this.from,
    required this.to,
    required this.taxType,
    required this.color,
    required this.type,
  });

  factory BondTypeModel.fromJson(Map<String, dynamic> json) {
    return BondTypeModel(
      label: json['label'] as String,
      value: json['value'] as String,
      typeGuide: json['typeGuide'] as String,
      from: json['from'] as int,
      to: json['to'] as int,
      taxType: json['taxType'] as int,
      color: json['color'] as String,
      type: BondType.byName(json['type'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'typeGuide': typeGuide,
      'from': from,
      'to': to,
      'taxType': taxType,
      'color': color,
      'type': type.name,
    };
  }

  @override
  List<Object?> get props => [
        label,
        value,
        typeGuide,
        from,
        to,
        taxType,
        color,
        type,
      ];
}

//
// class BondType {
//   final String? type;
//   final String? name;
//   final String? latinName;
//   final int? from;
//   final int? to;
//   final int? taxType;
//
//   BondType({
//     required this.type,
//     required this.name,
//     required this.latinName,
//     required this.from,
//     required this.to,
//     required this.taxType,
//   });
//
//   factory BondType.fromJson(Map<String, dynamic> json) {
//     return BondType(
//       type: json['Type'],
//       name: json['Name'],
//       latinName: json['LatinName'],
//       from: json['From'],
//       to: json['To'],
//       taxType: json['TaxType'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'Type': type,
//       'Name': name,
//       'LatinName': latinName,
//       'From': from,
//       'To': to,
//       'TaxType': taxType,
//     };
//   }
// }

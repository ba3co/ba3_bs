import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';


@HiveType(typeId: 1) // Use a different typeId than BondTypeModel
class ChequeType extends HiveObject with EquatableMixin {
  @HiveField(1)
  final int from;

  @HiveField(2)
  final int to;

  @HiveField(3)
  final String label;

  @HiveField(4)
  final String typeGuide;

  @HiveField(5)
  final String value;

  ChequeType({
    required this.from,
    required this.to,
    required this.label,
    required this.typeGuide,
    required this.value,
  });

  factory ChequeType.fromMap(Map<String, dynamic> map) {
    return ChequeType(
      from: map['from'] ?? 0,
      to: map['to'] ?? 0,
      label: map['label'] ?? '',
      typeGuide: map['typeGuide'] ?? '',
      value: map['value'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'from': from,
      'to': to,
      'label': label,
      'typeGuide': typeGuide,
      'value': value,
    };
  }

  @override
  List<Object?> get props => [
    from,
    to,
    label,
    typeGuide,
    value,
  ];
}

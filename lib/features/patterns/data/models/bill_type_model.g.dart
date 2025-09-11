// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_type_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BillTypeModelAdapter extends TypeAdapter<BillTypeModel> {
  @override
  final int typeId = 4;

  @override
  BillTypeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BillTypeModel(
      id: fields[0] as String?,
      billTypeId: fields[1] as String?,
      shortName: fields[2] as String?,
      fullName: fields[3] as String?,
      latinShortName: fields[4] as String?,
      latinFullName: fields[5] as String?,
      billTypeLabel: fields[6] as String?,
      color: fields[7] as int?,
      accounts: (fields[9] as Map?)?.cast<Account, AccountModel>(),
      discountAdditionAccounts: (fields[10] as Map?)?.map(
          (dynamic k, dynamic v) => MapEntry(
              k as Account, (v as List).cast<DiscountAdditionAccountModel>())),
      billPatternType: fields[8] as BillPatternType?,
    );
  }

  @override
  void write(BinaryWriter writer, BillTypeModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.billTypeId)
      ..writeByte(2)
      ..write(obj.shortName)
      ..writeByte(3)
      ..write(obj.fullName)
      ..writeByte(4)
      ..write(obj.latinShortName)
      ..writeByte(5)
      ..write(obj.latinFullName)
      ..writeByte(6)
      ..write(obj.billTypeLabel)
      ..writeByte(7)
      ..write(obj.color)
      ..writeByte(8)
      ..write(obj.billPatternType)
      ..writeByte(9)
      ..write(obj.accounts)
      ..writeByte(10)
      ..write(obj.discountAdditionAccounts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillTypeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

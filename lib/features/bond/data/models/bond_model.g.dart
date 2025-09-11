// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bond_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BondModelAdapter extends TypeAdapter<BondModel> {
  @override
  final int typeId = 13;

  @override
  BondModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BondModel(
      payTypeGuid: fields[0] as String?,
      payNumber: fields[1] as int?,
      payGuid: fields[2] as String?,
      payBranchGuid: fields[3] as String?,
      payDate: fields[4] as String?,
      entryPostDate: fields[5] as String?,
      payNote: fields[6] as String?,
      payCurrencyGuid: fields[7] as String?,
      payCurVal: fields[8] as double?,
      payAccountGuid: fields[9] as String?,
      paySecurity: fields[10] as int?,
      paySkip: fields[11] as int?,
      erParentType: fields[12] as int?,
      payItems: fields[13] as PayItems,
      e: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BondModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.payTypeGuid)
      ..writeByte(1)
      ..write(obj.payNumber)
      ..writeByte(2)
      ..write(obj.payGuid)
      ..writeByte(3)
      ..write(obj.payBranchGuid)
      ..writeByte(4)
      ..write(obj.payDate)
      ..writeByte(5)
      ..write(obj.entryPostDate)
      ..writeByte(6)
      ..write(obj.payNote)
      ..writeByte(7)
      ..write(obj.payCurrencyGuid)
      ..writeByte(8)
      ..write(obj.payCurVal)
      ..writeByte(9)
      ..write(obj.payAccountGuid)
      ..writeByte(10)
      ..write(obj.paySecurity)
      ..writeByte(11)
      ..write(obj.paySkip)
      ..writeByte(12)
      ..write(obj.erParentType)
      ..writeByte(13)
      ..write(obj.payItems)
      ..writeByte(14)
      ..write(obj.e);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BondModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

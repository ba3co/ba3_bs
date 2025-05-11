// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pay_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PayItemsAdapter extends TypeAdapter<PayItems> {
  @override
  final int typeId = 14;

  @override
  PayItems read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PayItems(
      itemList: (fields[0] as List).cast<PayItem>(),
    );
  }

  @override
  void write(BinaryWriter writer, PayItems obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.itemList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PayItemsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PayItemAdapter extends TypeAdapter<PayItem> {
  @override
  final int typeId = 15;

  @override
  PayItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PayItem(
      entryAccountGuid: fields[0] as String?,
      entryAccountName: fields[1] as String?,
      entryDate: fields[2] as String?,
      entryDebit: fields[3] as double?,
      entryCredit: fields[4] as double?,
      entryNote: fields[5] as String?,
      entryCurrencyGuid: fields[6] as String?,
      entryCurrencyVal: fields[7] as double?,
      entryCostGuid: fields[8] as String?,
      entryClass: fields[9] as String?,
      entryNumber: fields[10] as int?,
      entryCustomerGuid: fields[11] as String?,
      entryType: fields[12] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, PayItem obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.entryAccountGuid)
      ..writeByte(1)
      ..write(obj.entryAccountName)
      ..writeByte(2)
      ..write(obj.entryDate)
      ..writeByte(3)
      ..write(obj.entryDebit)
      ..writeByte(4)
      ..write(obj.entryCredit)
      ..writeByte(5)
      ..write(obj.entryNote)
      ..writeByte(6)
      ..write(obj.entryCurrencyGuid)
      ..writeByte(7)
      ..write(obj.entryCurrencyVal)
      ..writeByte(8)
      ..write(obj.entryCostGuid)
      ..writeByte(9)
      ..write(obj.entryClass)
      ..writeByte(10)
      ..write(obj.entryNumber)
      ..writeByte(11)
      ..write(obj.entryCustomerGuid)
      ..writeByte(12)
      ..write(obj.entryType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PayItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

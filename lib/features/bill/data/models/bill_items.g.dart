// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_items.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BillItemsAdapter extends TypeAdapter<BillItems> {
  @override
  final int typeId = 5;

  @override
  BillItems read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BillItems(
      itemList: (fields[0] as List).cast<BillItem>(),
    );
  }

  @override
  void write(BinaryWriter writer, BillItems obj) {
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
      other is BillItemsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BillItemAdapter extends TypeAdapter<BillItem> {
  @override
  final int typeId = 6;

  @override
  BillItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BillItem(
      itemGuid: fields[0] as String,
      itemName: fields[1] as String?,
      itemQuantity: fields[2] as int,
      itemTotalPrice: fields[3] as String,
      itemSubTotalPrice: fields[4] as double?,
      itemVatPrice: fields[5] as double?,
      itemGiftsNumber: fields[6] as int?,
      itemGiftsPrice: fields[7] as double?,
      soldSerialNumber: fields[8] as String?,
      itemSerialNumbers: (fields[9] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, BillItem obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.itemGuid)
      ..writeByte(1)
      ..write(obj.itemName)
      ..writeByte(2)
      ..write(obj.itemQuantity)
      ..writeByte(3)
      ..write(obj.itemTotalPrice)
      ..writeByte(4)
      ..write(obj.itemSubTotalPrice)
      ..writeByte(5)
      ..write(obj.itemVatPrice)
      ..writeByte(6)
      ..write(obj.itemGiftsNumber)
      ..writeByte(7)
      ..write(obj.itemGiftsPrice)
      ..writeByte(8)
      ..write(obj.soldSerialNumber)
      ..writeByte(9)
      ..write(obj.itemSerialNumbers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

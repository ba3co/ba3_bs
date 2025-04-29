// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_details.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BillDetailsAdapter extends TypeAdapter<BillDetails> {
  @override
  final int typeId = 7;

  @override
  BillDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BillDetails(
      billGuid: fields[0] as String?,
      billPayType: fields[1] as int?,
      billNumber: fields[2] as int?,
      previous: fields[3] as int?,
      next: fields[4] as int?,
      billDate: fields[5] as DateTime?,
      billNote: fields[6] as String?,
      orderNumber: fields[7] as String?,
      customerPhone: fields[8] as String?,
      billCustomerId: fields[10] as String?,
      billAccountId: fields[11] as String?,
      billTotal: fields[12] as double?,
      billVatTotal: fields[13] as double?,
      billBeforeVatTotal: fields[14] as double?,
      billSellerId: fields[9] as String?,
      billGiftsTotal: fields[15] as double?,
      billDiscountsTotal: fields[16] as double?,
      billAdditionsTotal: fields[17] as double?,
      billFirstPay: fields[18] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, BillDetails obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.billGuid)
      ..writeByte(1)
      ..write(obj.billPayType)
      ..writeByte(2)
      ..write(obj.billNumber)
      ..writeByte(3)
      ..write(obj.previous)
      ..writeByte(4)
      ..write(obj.next)
      ..writeByte(5)
      ..write(obj.billDate)
      ..writeByte(6)
      ..write(obj.billNote)
      ..writeByte(7)
      ..write(obj.orderNumber)
      ..writeByte(8)
      ..write(obj.customerPhone)
      ..writeByte(9)
      ..write(obj.billSellerId)
      ..writeByte(10)
      ..write(obj.billCustomerId)
      ..writeByte(11)
      ..write(obj.billAccountId)
      ..writeByte(12)
      ..write(obj.billTotal)
      ..writeByte(13)
      ..write(obj.billVatTotal)
      ..writeByte(14)
      ..write(obj.billBeforeVatTotal)
      ..writeByte(15)
      ..write(obj.billGiftsTotal)
      ..writeByte(16)
      ..write(obj.billDiscountsTotal)
      ..writeByte(17)
      ..write(obj.billAdditionsTotal)
      ..writeByte(18)
      ..write(obj.billFirstPay);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillDetailsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

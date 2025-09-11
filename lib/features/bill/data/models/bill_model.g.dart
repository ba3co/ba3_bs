// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BillModelAdapter extends TypeAdapter<BillModel> {
  @override
  final int typeId = 3;

  @override
  BillModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BillModel(
      billId: fields[0] as String?,
      billTypeModel: fields[1] as BillTypeModel,
      items: fields[2] as BillItems,
      billDetails: fields[3] as BillDetails,
      status: fields[5] as Status,
      freeBill: fields[4] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, BillModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.billId)
      ..writeByte(1)
      ..write(obj.billTypeModel)
      ..writeByte(2)
      ..write(obj.items)
      ..writeByte(3)
      ..write(obj.billDetails)
      ..writeByte(4)
      ..write(obj.freeBill)
      ..writeByte(5)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

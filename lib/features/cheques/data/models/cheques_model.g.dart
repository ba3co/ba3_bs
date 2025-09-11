// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cheques_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChequesModelAdapter extends TypeAdapter<ChequesModel> {
  @override
  final int typeId = 17;

  @override
  ChequesModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChequesModel(
      chequesTypeGuid: fields[0] as String?,
      chequesNumber: fields[1] as int?,
      chequesNum: fields[2] as int?,
      chequesGuid: fields[3] as String?,
      chequesDate: fields[4] as String?,
      chequesDueDate: fields[5] as String?,
      chequesNote: fields[6] as String?,
      chequesVal: fields[7] as double?,
      accPtr: fields[9] as String?,
      chequesAccount2Guid: fields[8] as String?,
      chequesAccount2Name: fields[11] as String?,
      accPtrName: fields[10] as String?,
      isPayed: fields[16] as bool?,
      chequesPayGuid: fields[12] as String?,
      chequesRefundPayGuid: fields[13] as String?,
      isRefund: fields[17] as bool?,
      chequesPayDate: fields[14] as String?,
      chequesRefundPayDate: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ChequesModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.chequesTypeGuid)
      ..writeByte(1)
      ..write(obj.chequesNumber)
      ..writeByte(2)
      ..write(obj.chequesNum)
      ..writeByte(3)
      ..write(obj.chequesGuid)
      ..writeByte(4)
      ..write(obj.chequesDate)
      ..writeByte(5)
      ..write(obj.chequesDueDate)
      ..writeByte(6)
      ..write(obj.chequesNote)
      ..writeByte(7)
      ..write(obj.chequesVal)
      ..writeByte(8)
      ..write(obj.chequesAccount2Guid)
      ..writeByte(9)
      ..write(obj.accPtr)
      ..writeByte(10)
      ..write(obj.accPtrName)
      ..writeByte(11)
      ..write(obj.chequesAccount2Name)
      ..writeByte(12)
      ..write(obj.chequesPayGuid)
      ..writeByte(13)
      ..write(obj.chequesRefundPayGuid)
      ..writeByte(14)
      ..write(obj.chequesPayDate)
      ..writeByte(15)
      ..write(obj.chequesRefundPayDate)
      ..writeByte(16)
      ..write(obj.isPayed)
      ..writeByte(17)
      ..write(obj.isRefund);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChequesModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

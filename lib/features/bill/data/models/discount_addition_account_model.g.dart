// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discount_addition_account_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiscountAdditionAccountModelAdapter
    extends TypeAdapter<DiscountAdditionAccountModel> {
  @override
  final int typeId = 11;

  @override
  DiscountAdditionAccountModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DiscountAdditionAccountModel(
      accName: fields[1] as String,
      id: fields[0] as String,
      amount: fields[26] as double,
      percentage: fields[27] as double,
    );
  }

  @override
  void write(BinaryWriter writer, DiscountAdditionAccountModel obj) {
    writer
      ..writeByte(28)
      ..writeByte(26)
      ..write(obj.amount)
      ..writeByte(27)
      ..write(obj.percentage)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.accName)
      ..writeByte(2)
      ..write(obj.accLatinName)
      ..writeByte(3)
      ..write(obj.accCode)
      ..writeByte(4)
      ..write(obj.accCDate)
      ..writeByte(5)
      ..write(obj.accCheckDate)
      ..writeByte(6)
      ..write(obj.accParentGuid)
      ..writeByte(7)
      ..write(obj.accParentName)
      ..writeByte(8)
      ..write(obj.accFinalGuid)
      ..writeByte(9)
      ..write(obj.accAccNSons)
      ..writeByte(10)
      ..write(obj.accInitDebit)
      ..writeByte(11)
      ..write(obj.accInitCredit)
      ..writeByte(12)
      ..write(obj.maxDebit)
      ..writeByte(13)
      ..write(obj.accWarn)
      ..writeByte(14)
      ..write(obj.note)
      ..writeByte(15)
      ..write(obj.accCurVal)
      ..writeByte(16)
      ..write(obj.accCurGuid)
      ..writeByte(17)
      ..write(obj.accSecurity)
      ..writeByte(18)
      ..write(obj.accDebitOrCredit)
      ..writeByte(19)
      ..write(obj.accType)
      ..writeByte(20)
      ..write(obj.accState)
      ..writeByte(21)
      ..write(obj.accIsChangableRatio)
      ..writeByte(22)
      ..write(obj.accBranchGuid)
      ..writeByte(23)
      ..write(obj.accNumber)
      ..writeByte(24)
      ..write(obj.accBranchMask)
      ..writeByte(25)
      ..write(obj.accCustomer);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscountAdditionAccountModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

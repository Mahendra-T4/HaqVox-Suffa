// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 1;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      userKey: fields[0] as String?,
      firstName: fields[1] as String?,
      lastName: fields[2] as String?,
      email: fields[3] as String?,
      mobile: fields[4] as String?,
      alternateNumber: fields[5] as String?,
      dateOfBirth: fields[6] as String?,
      gender: fields[7] as String?,
      genderName: fields[8] as String?,
      userCode: fields[9] as String?,
      profileImage: fields[10] as String?,
      localProfileImagePath: fields[11] as String?,
      subscriptionStatus: fields[12] as int?,
      isLoggedIn: fields[13] as bool,
      createdAt: fields[14] as DateTime?,
      updatedAt: fields[15] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.userKey)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.mobile)
      ..writeByte(5)
      ..write(obj.alternateNumber)
      ..writeByte(6)
      ..write(obj.dateOfBirth)
      ..writeByte(7)
      ..write(obj.gender)
      ..writeByte(8)
      ..write(obj.genderName)
      ..writeByte(9)
      ..write(obj.userCode)
      ..writeByte(10)
      ..write(obj.profileImage)
      ..writeByte(11)
      ..write(obj.localProfileImagePath)
      ..writeByte(12)
      ..write(obj.subscriptionStatus)
      ..writeByte(13)
      ..write(obj.isLoggedIn)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

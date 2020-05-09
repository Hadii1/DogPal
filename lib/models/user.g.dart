// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final typeId = 0;

  @override
  User read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      username: fields[0] as String,
      email: fields[1] as String,
      photo: fields[2] as String,
      uid: fields[3] as String,
      firstName: fields[7] as String,
      favoritePosts: (fields[5] as Map)?.cast<String, String>(),
      dataJoined: fields[4] as DateTime,
      phoneNumber: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.photo)
      ..writeByte(3)
      ..write(obj.uid)
      ..writeByte(4)
      ..write(obj.dataJoined)
      ..writeByte(5)
      ..write(obj.favoritePosts)
      ..writeByte(6)
      ..write(obj.phoneNumber)
      ..writeByte(7)
      ..write(obj.firstName);
  }
}

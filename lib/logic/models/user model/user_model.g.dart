// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  name: json['name'] as String,
  email: json['email'] as String,
  password: json['password'] as String,
  imgUrl: json['imgUrl'] as String?,
  banks:
      (json['banks'] as List<dynamic>?)
          ?.map((e) => BankModel.fromJson(e as Map<String, dynamic>))
          .toList(),
  wallets:
      (json['wallets'] as List<dynamic>?)
          ?.map((e) => WalletModel.fromJson(e as Map<String, dynamic>))
          .toList(),
  age: (json['age'] as num).toInt(),
  pin: json['pin'] as String,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'imgUrl': instance.imgUrl,
      'banks': instance.banks,
      'wallets': instance.wallets,
      'age': instance.age,
      'pin': instance.pin,
    };

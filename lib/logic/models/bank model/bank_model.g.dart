// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BankModel _$BankModelFromJson(Map<String, dynamic> json) => _BankModel(
  bankName: json['bankName'] as String,
  amount: (json['amount'] as num).toInt(),
);

Map<String, dynamic> _$BankModelToJson(_BankModel instance) =>
    <String, dynamic>{'bankName': instance.bankName, 'amount': instance.amount};

import 'package:freezed_annotation/freezed_annotation.dart';

// required: associates our `main.dart` with the code generated by Freezed
part 'bank_name_model.freezed.dart';
// optional: Since our BankNameModel class is serializable, we must add this line.
// But if BankNameModel was not serializable, we could skip it.
part 'bank_name_model.g.dart';

@freezed
abstract class BankNameModel with _$BankNameModel {
  const factory BankNameModel({required String bankName}) = _BankNameModel;

  factory BankNameModel.fromJson(Map<String, Object?> json) =>
      _$BankNameModelFromJson(json);
}

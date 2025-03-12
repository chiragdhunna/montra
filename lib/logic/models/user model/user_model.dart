import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:montra/logic/models/bank%20model/bank_model.dart';
import 'package:montra/logic/models/wallet%20model/wallet_model.dart';

// required: associates our `main.dart` with the code generated by Freezed
part 'user_model.freezed.dart';
// optional: Since our UserModel class is serializable, we must add this line.
// But if UserModel was not serializable, we could skip it.
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String name,
    required String email,
    required String password,
    String? imgUrl,
    List<BankModel>? banks,
    List<WalletModel>? wallets,
    required int age,
    required String pin,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, Object?> json) =>
      _$UserModelFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

// required: associates our `main.dart` with the code generated by Freezed
part 'wallet_name_model.freezed.dart';
// optional: Since our WalletNameModel class is serializable, we must add this line.
// But if WalletNameModel was not serializable, we could skip it.
part 'wallet_name_model.g.dart';

@freezed
abstract class WalletNameModel with _$WalletNameModel {
  const factory WalletNameModel({required String walletName}) =
      _WalletNameModel;

  factory WalletNameModel.fromJson(Map<String, Object?> json) =>
      _$WalletNameModelFromJson(json);
}

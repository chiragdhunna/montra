import 'package:freezed_annotation/freezed_annotation.dart';

// required: associates our `main.dart` with the code generated by Freezed
part 'wallet_model.freezed.dart';
// optional: Since our WalletModel class is serializable, we must add this line.
// But if WalletModel was not serializable, we could skip it.
part 'wallet_model.g.dart';

@freezed
abstract class WalletModel with _$WalletModel {
  const factory WalletModel({
    required String name,
    required int amount,
    required String userId,
    required String walletNumber,
  }) = _WalletModel;

  factory WalletModel.fromJson(Map<String, Object?> json) =>
      _$WalletModelFromJson(json);
}

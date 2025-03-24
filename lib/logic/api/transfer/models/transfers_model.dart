import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:montra/logic/api/transfer/models/transfer_model.dart';

// required: associates our `main.dart` with the code generated by Freezed
part 'transfers_model.freezed.dart';
// optional: Since our TransfersModel class is serializable, we must add this line.
// But if TransfersModel was not serializable, we could skip it.
part 'transfers_model.g.dart';

@freezed
abstract class TransfersModel with _$TransfersModel {
  const factory TransfersModel({required List<TransferModel> transfers}) =
      _TransfersModel;

  factory TransfersModel.fromJson(Map<String, Object?> json) =>
      _$TransfersModelFromJson(json);
}

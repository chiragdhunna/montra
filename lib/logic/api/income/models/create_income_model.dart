import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_income_model.freezed.dart';
part 'create_income_model.g.dart';

/// Custom converter for FormData
class FormDataConverter
    implements JsonConverter<FormData?, Map<String, dynamic>?> {
  const FormDataConverter();

  @override
  FormData? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    // You may need a custom deserialization logic depending on how FormData should be reconstructed
    return FormData.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(FormData? object) {
    if (object == null) return null;
    return {}; // FormData cannot be directly serialized; return an empty map or handle as needed
  }
}

@freezed
abstract class CreateIncomeModel with _$CreateIncomeModel {
  const factory CreateIncomeModel({
    required int amount,
    required String source,

    @FormDataConverter() // Apply the custom converter
    FormData? attachment,

    required String description,
  }) = _CreateIncomeModel;

  factory CreateIncomeModel.fromJson(Map<String, Object?> json) =>
      _$CreateIncomeModelFromJson(json);
}

// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel {

 String get name; String get email; String get password; String? get imgUrl; List<BankModel>? get banks; List<WalletModel>? get wallets; int get age; String get pin;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.imgUrl, imgUrl) || other.imgUrl == imgUrl)&&const DeepCollectionEquality().equals(other.banks, banks)&&const DeepCollectionEquality().equals(other.wallets, wallets)&&(identical(other.age, age) || other.age == age)&&(identical(other.pin, pin) || other.pin == pin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,email,password,imgUrl,const DeepCollectionEquality().hash(banks),const DeepCollectionEquality().hash(wallets),age,pin);

@override
String toString() {
  return 'UserModel(name: $name, email: $email, password: $password, imgUrl: $imgUrl, banks: $banks, wallets: $wallets, age: $age, pin: $pin)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 String name, String email, String password, String? imgUrl, List<BankModel>? banks, List<WalletModel>? wallets, int age, String pin
});




}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? email = null,Object? password = null,Object? imgUrl = freezed,Object? banks = freezed,Object? wallets = freezed,Object? age = null,Object? pin = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,imgUrl: freezed == imgUrl ? _self.imgUrl : imgUrl // ignore: cast_nullable_to_non_nullable
as String?,banks: freezed == banks ? _self.banks : banks // ignore: cast_nullable_to_non_nullable
as List<BankModel>?,wallets: freezed == wallets ? _self.wallets : wallets // ignore: cast_nullable_to_non_nullable
as List<WalletModel>?,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,pin: null == pin ? _self.pin : pin // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _UserModel implements UserModel {
  const _UserModel({required this.name, required this.email, required this.password, this.imgUrl, final  List<BankModel>? banks, final  List<WalletModel>? wallets, required this.age, required this.pin}): _banks = banks,_wallets = wallets;
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override final  String name;
@override final  String email;
@override final  String password;
@override final  String? imgUrl;
 final  List<BankModel>? _banks;
@override List<BankModel>? get banks {
  final value = _banks;
  if (value == null) return null;
  if (_banks is EqualUnmodifiableListView) return _banks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<WalletModel>? _wallets;
@override List<WalletModel>? get wallets {
  final value = _wallets;
  if (value == null) return null;
  if (_wallets is EqualUnmodifiableListView) return _wallets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  int age;
@override final  String pin;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.imgUrl, imgUrl) || other.imgUrl == imgUrl)&&const DeepCollectionEquality().equals(other._banks, _banks)&&const DeepCollectionEquality().equals(other._wallets, _wallets)&&(identical(other.age, age) || other.age == age)&&(identical(other.pin, pin) || other.pin == pin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,email,password,imgUrl,const DeepCollectionEquality().hash(_banks),const DeepCollectionEquality().hash(_wallets),age,pin);

@override
String toString() {
  return 'UserModel(name: $name, email: $email, password: $password, imgUrl: $imgUrl, banks: $banks, wallets: $wallets, age: $age, pin: $pin)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
 String name, String email, String password, String? imgUrl, List<BankModel>? banks, List<WalletModel>? wallets, int age, String pin
});




}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? email = null,Object? password = null,Object? imgUrl = freezed,Object? banks = freezed,Object? wallets = freezed,Object? age = null,Object? pin = null,}) {
  return _then(_UserModel(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,imgUrl: freezed == imgUrl ? _self.imgUrl : imgUrl // ignore: cast_nullable_to_non_nullable
as String?,banks: freezed == banks ? _self._banks : banks // ignore: cast_nullable_to_non_nullable
as List<BankModel>?,wallets: freezed == wallets ? _self._wallets : wallets // ignore: cast_nullable_to_non_nullable
as List<WalletModel>?,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,pin: null == pin ? _self.pin : pin // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

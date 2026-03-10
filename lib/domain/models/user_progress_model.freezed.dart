// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_progress_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserProgressModel {

 int get id; int get totalPoints; int get currentLevel; int get currentStreak; DateTime? get lastCompletionDate; bool get weeklyStreakRewardClaimed;
/// Create a copy of UserProgressModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProgressModelCopyWith<UserProgressModel> get copyWith => _$UserProgressModelCopyWithImpl<UserProgressModel>(this as UserProgressModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProgressModel&&(identical(other.id, id) || other.id == id)&&(identical(other.totalPoints, totalPoints) || other.totalPoints == totalPoints)&&(identical(other.currentLevel, currentLevel) || other.currentLevel == currentLevel)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.lastCompletionDate, lastCompletionDate) || other.lastCompletionDate == lastCompletionDate)&&(identical(other.weeklyStreakRewardClaimed, weeklyStreakRewardClaimed) || other.weeklyStreakRewardClaimed == weeklyStreakRewardClaimed));
}


@override
int get hashCode => Object.hash(runtimeType,id,totalPoints,currentLevel,currentStreak,lastCompletionDate,weeklyStreakRewardClaimed);

@override
String toString() {
  return 'UserProgressModel(id: $id, totalPoints: $totalPoints, currentLevel: $currentLevel, currentStreak: $currentStreak, lastCompletionDate: $lastCompletionDate, weeklyStreakRewardClaimed: $weeklyStreakRewardClaimed)';
}


}

/// @nodoc
abstract mixin class $UserProgressModelCopyWith<$Res>  {
  factory $UserProgressModelCopyWith(UserProgressModel value, $Res Function(UserProgressModel) _then) = _$UserProgressModelCopyWithImpl;
@useResult
$Res call({
 int id, int totalPoints, int currentLevel, int currentStreak, DateTime? lastCompletionDate, bool weeklyStreakRewardClaimed
});




}
/// @nodoc
class _$UserProgressModelCopyWithImpl<$Res>
    implements $UserProgressModelCopyWith<$Res> {
  _$UserProgressModelCopyWithImpl(this._self, this._then);

  final UserProgressModel _self;
  final $Res Function(UserProgressModel) _then;

/// Create a copy of UserProgressModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? totalPoints = null,Object? currentLevel = null,Object? currentStreak = null,Object? lastCompletionDate = freezed,Object? weeklyStreakRewardClaimed = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,totalPoints: null == totalPoints ? _self.totalPoints : totalPoints // ignore: cast_nullable_to_non_nullable
as int,currentLevel: null == currentLevel ? _self.currentLevel : currentLevel // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,lastCompletionDate: freezed == lastCompletionDate ? _self.lastCompletionDate : lastCompletionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,weeklyStreakRewardClaimed: null == weeklyStreakRewardClaimed ? _self.weeklyStreakRewardClaimed : weeklyStreakRewardClaimed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProgressModel].
extension UserProgressModelPatterns on UserProgressModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProgressModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProgressModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProgressModel value)  $default,){
final _that = this;
switch (_that) {
case _UserProgressModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProgressModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserProgressModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int totalPoints,  int currentLevel,  int currentStreak,  DateTime? lastCompletionDate,  bool weeklyStreakRewardClaimed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProgressModel() when $default != null:
return $default(_that.id,_that.totalPoints,_that.currentLevel,_that.currentStreak,_that.lastCompletionDate,_that.weeklyStreakRewardClaimed);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int totalPoints,  int currentLevel,  int currentStreak,  DateTime? lastCompletionDate,  bool weeklyStreakRewardClaimed)  $default,) {final _that = this;
switch (_that) {
case _UserProgressModel():
return $default(_that.id,_that.totalPoints,_that.currentLevel,_that.currentStreak,_that.lastCompletionDate,_that.weeklyStreakRewardClaimed);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int totalPoints,  int currentLevel,  int currentStreak,  DateTime? lastCompletionDate,  bool weeklyStreakRewardClaimed)?  $default,) {final _that = this;
switch (_that) {
case _UserProgressModel() when $default != null:
return $default(_that.id,_that.totalPoints,_that.currentLevel,_that.currentStreak,_that.lastCompletionDate,_that.weeklyStreakRewardClaimed);case _:
  return null;

}
}

}

/// @nodoc


class _UserProgressModel extends UserProgressModel {
   _UserProgressModel({required this.id, required this.totalPoints, required this.currentLevel, required this.currentStreak, required this.lastCompletionDate, required this.weeklyStreakRewardClaimed}): super._();
  

@override final  int id;
@override final  int totalPoints;
@override final  int currentLevel;
@override final  int currentStreak;
@override final  DateTime? lastCompletionDate;
@override final  bool weeklyStreakRewardClaimed;

/// Create a copy of UserProgressModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProgressModelCopyWith<_UserProgressModel> get copyWith => __$UserProgressModelCopyWithImpl<_UserProgressModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProgressModel&&(identical(other.id, id) || other.id == id)&&(identical(other.totalPoints, totalPoints) || other.totalPoints == totalPoints)&&(identical(other.currentLevel, currentLevel) || other.currentLevel == currentLevel)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.lastCompletionDate, lastCompletionDate) || other.lastCompletionDate == lastCompletionDate)&&(identical(other.weeklyStreakRewardClaimed, weeklyStreakRewardClaimed) || other.weeklyStreakRewardClaimed == weeklyStreakRewardClaimed));
}


@override
int get hashCode => Object.hash(runtimeType,id,totalPoints,currentLevel,currentStreak,lastCompletionDate,weeklyStreakRewardClaimed);

@override
String toString() {
  return 'UserProgressModel(id: $id, totalPoints: $totalPoints, currentLevel: $currentLevel, currentStreak: $currentStreak, lastCompletionDate: $lastCompletionDate, weeklyStreakRewardClaimed: $weeklyStreakRewardClaimed)';
}


}

/// @nodoc
abstract mixin class _$UserProgressModelCopyWith<$Res> implements $UserProgressModelCopyWith<$Res> {
  factory _$UserProgressModelCopyWith(_UserProgressModel value, $Res Function(_UserProgressModel) _then) = __$UserProgressModelCopyWithImpl;
@override @useResult
$Res call({
 int id, int totalPoints, int currentLevel, int currentStreak, DateTime? lastCompletionDate, bool weeklyStreakRewardClaimed
});




}
/// @nodoc
class __$UserProgressModelCopyWithImpl<$Res>
    implements _$UserProgressModelCopyWith<$Res> {
  __$UserProgressModelCopyWithImpl(this._self, this._then);

  final _UserProgressModel _self;
  final $Res Function(_UserProgressModel) _then;

/// Create a copy of UserProgressModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? totalPoints = null,Object? currentLevel = null,Object? currentStreak = null,Object? lastCompletionDate = freezed,Object? weeklyStreakRewardClaimed = null,}) {
  return _then(_UserProgressModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,totalPoints: null == totalPoints ? _self.totalPoints : totalPoints // ignore: cast_nullable_to_non_nullable
as int,currentLevel: null == currentLevel ? _self.currentLevel : currentLevel // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,lastCompletionDate: freezed == lastCompletionDate ? _self.lastCompletionDate : lastCompletionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,weeklyStreakRewardClaimed: null == weeklyStreakRewardClaimed ? _self.weeklyStreakRewardClaimed : weeklyStreakRewardClaimed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

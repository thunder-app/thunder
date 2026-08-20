// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'modlog_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ModlogState {

/// The status of the modlog feed.
 ModlogStatus get status;/// The type of modlog action to filter by.
 ModlogActionType get modlogActionType;/// A community ID to filter the modlog by.
 int? get communityId;/// A user ID to filter the modlog by.
 int? get userId;/// A moderator ID to filter the modlog by.
 int? get moderatorId;/// A comment ID to filter the modlog by.
 int? get commentId;/// The list of modlog events.
 List<ModlogEventItem> get modlogEventItems;/// Whether the end of the modlog has been reached.
 bool get hasReachedEnd;/// The current page of the modlog.
 int get currentPage;/// The error message to display after a failure.
 String? get message;
/// Create a copy of ModlogState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModlogStateCopyWith<ModlogState> get copyWith => _$ModlogStateCopyWithImpl<ModlogState>(this as ModlogState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModlogState&&(identical(other.status, status) || other.status == status)&&(identical(other.modlogActionType, modlogActionType) || other.modlogActionType == modlogActionType)&&(identical(other.communityId, communityId) || other.communityId == communityId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.moderatorId, moderatorId) || other.moderatorId == moderatorId)&&(identical(other.commentId, commentId) || other.commentId == commentId)&&const DeepCollectionEquality().equals(other.modlogEventItems, modlogEventItems)&&(identical(other.hasReachedEnd, hasReachedEnd) || other.hasReachedEnd == hasReachedEnd)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,status,modlogActionType,communityId,userId,moderatorId,commentId,const DeepCollectionEquality().hash(modlogEventItems),hasReachedEnd,currentPage,message);

@override
String toString() {
  return 'ModlogState(status: $status, modlogActionType: $modlogActionType, communityId: $communityId, userId: $userId, moderatorId: $moderatorId, commentId: $commentId, modlogEventItems: $modlogEventItems, hasReachedEnd: $hasReachedEnd, currentPage: $currentPage, message: $message)';
}


}

/// @nodoc
abstract mixin class $ModlogStateCopyWith<$Res>  {
  factory $ModlogStateCopyWith(ModlogState value, $Res Function(ModlogState) _then) = _$ModlogStateCopyWithImpl;
@useResult
$Res call({
 ModlogStatus status, ModlogActionType modlogActionType, int? communityId, int? userId, int? moderatorId, int? commentId, List<ModlogEventItem> modlogEventItems, bool hasReachedEnd, int currentPage, String? message
});




}
/// @nodoc
class _$ModlogStateCopyWithImpl<$Res>
    implements $ModlogStateCopyWith<$Res> {
  _$ModlogStateCopyWithImpl(this._self, this._then);

  final ModlogState _self;
  final $Res Function(ModlogState) _then;

/// Create a copy of ModlogState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? modlogActionType = null,Object? communityId = freezed,Object? userId = freezed,Object? moderatorId = freezed,Object? commentId = freezed,Object? modlogEventItems = null,Object? hasReachedEnd = null,Object? currentPage = null,Object? message = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ModlogStatus,modlogActionType: null == modlogActionType ? _self.modlogActionType : modlogActionType // ignore: cast_nullable_to_non_nullable
as ModlogActionType,communityId: freezed == communityId ? _self.communityId : communityId // ignore: cast_nullable_to_non_nullable
as int?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,moderatorId: freezed == moderatorId ? _self.moderatorId : moderatorId // ignore: cast_nullable_to_non_nullable
as int?,commentId: freezed == commentId ? _self.commentId : commentId // ignore: cast_nullable_to_non_nullable
as int?,modlogEventItems: null == modlogEventItems ? _self.modlogEventItems : modlogEventItems // ignore: cast_nullable_to_non_nullable
as List<ModlogEventItem>,hasReachedEnd: null == hasReachedEnd ? _self.hasReachedEnd : hasReachedEnd // ignore: cast_nullable_to_non_nullable
as bool,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ModlogState].
extension ModlogStatePatterns on ModlogState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModlogState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModlogState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModlogState value)  $default,){
final _that = this;
switch (_that) {
case _ModlogState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModlogState value)?  $default,){
final _that = this;
switch (_that) {
case _ModlogState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ModlogStatus status,  ModlogActionType modlogActionType,  int? communityId,  int? userId,  int? moderatorId,  int? commentId,  List<ModlogEventItem> modlogEventItems,  bool hasReachedEnd,  int currentPage,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModlogState() when $default != null:
return $default(_that.status,_that.modlogActionType,_that.communityId,_that.userId,_that.moderatorId,_that.commentId,_that.modlogEventItems,_that.hasReachedEnd,_that.currentPage,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ModlogStatus status,  ModlogActionType modlogActionType,  int? communityId,  int? userId,  int? moderatorId,  int? commentId,  List<ModlogEventItem> modlogEventItems,  bool hasReachedEnd,  int currentPage,  String? message)  $default,) {final _that = this;
switch (_that) {
case _ModlogState():
return $default(_that.status,_that.modlogActionType,_that.communityId,_that.userId,_that.moderatorId,_that.commentId,_that.modlogEventItems,_that.hasReachedEnd,_that.currentPage,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ModlogStatus status,  ModlogActionType modlogActionType,  int? communityId,  int? userId,  int? moderatorId,  int? commentId,  List<ModlogEventItem> modlogEventItems,  bool hasReachedEnd,  int currentPage,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _ModlogState() when $default != null:
return $default(_that.status,_that.modlogActionType,_that.communityId,_that.userId,_that.moderatorId,_that.commentId,_that.modlogEventItems,_that.hasReachedEnd,_that.currentPage,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _ModlogState extends ModlogState {
  const _ModlogState({this.status = ModlogStatus.initial, this.modlogActionType = ModlogActionType.all, this.communityId, this.userId, this.moderatorId, this.commentId, this.modlogEventItems = const [], this.hasReachedEnd = false, this.currentPage = 1, this.message}): super._();
  

/// The status of the modlog feed.
@override@JsonKey() final  ModlogStatus status;
/// The type of modlog action to filter by.
@override@JsonKey() final  ModlogActionType modlogActionType;
/// A community ID to filter the modlog by.
@override final  int? communityId;
/// A user ID to filter the modlog by.
@override final  int? userId;
/// A moderator ID to filter the modlog by.
@override final  int? moderatorId;
/// A comment ID to filter the modlog by.
@override final  int? commentId;
/// The list of modlog events.
@override@JsonKey() final  List<ModlogEventItem> modlogEventItems;
/// Whether the end of the modlog has been reached.
@override@JsonKey() final  bool hasReachedEnd;
/// The current page of the modlog.
@override@JsonKey() final  int currentPage;
/// The error message to display after a failure.
@override final  String? message;

/// Create a copy of ModlogState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModlogStateCopyWith<_ModlogState> get copyWith => __$ModlogStateCopyWithImpl<_ModlogState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModlogState&&(identical(other.status, status) || other.status == status)&&(identical(other.modlogActionType, modlogActionType) || other.modlogActionType == modlogActionType)&&(identical(other.communityId, communityId) || other.communityId == communityId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.moderatorId, moderatorId) || other.moderatorId == moderatorId)&&(identical(other.commentId, commentId) || other.commentId == commentId)&&const DeepCollectionEquality().equals(other.modlogEventItems, modlogEventItems)&&(identical(other.hasReachedEnd, hasReachedEnd) || other.hasReachedEnd == hasReachedEnd)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,status,modlogActionType,communityId,userId,moderatorId,commentId,const DeepCollectionEquality().hash(modlogEventItems),hasReachedEnd,currentPage,message);

@override
String toString() {
  return 'ModlogState(status: $status, modlogActionType: $modlogActionType, communityId: $communityId, userId: $userId, moderatorId: $moderatorId, commentId: $commentId, modlogEventItems: $modlogEventItems, hasReachedEnd: $hasReachedEnd, currentPage: $currentPage, message: $message)';
}


}

/// @nodoc
abstract mixin class _$ModlogStateCopyWith<$Res> implements $ModlogStateCopyWith<$Res> {
  factory _$ModlogStateCopyWith(_ModlogState value, $Res Function(_ModlogState) _then) = __$ModlogStateCopyWithImpl;
@override @useResult
$Res call({
 ModlogStatus status, ModlogActionType modlogActionType, int? communityId, int? userId, int? moderatorId, int? commentId, List<ModlogEventItem> modlogEventItems, bool hasReachedEnd, int currentPage, String? message
});




}
/// @nodoc
class __$ModlogStateCopyWithImpl<$Res>
    implements _$ModlogStateCopyWith<$Res> {
  __$ModlogStateCopyWithImpl(this._self, this._then);

  final _ModlogState _self;
  final $Res Function(_ModlogState) _then;

/// Create a copy of ModlogState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? modlogActionType = null,Object? communityId = freezed,Object? userId = freezed,Object? moderatorId = freezed,Object? commentId = freezed,Object? modlogEventItems = null,Object? hasReachedEnd = null,Object? currentPage = null,Object? message = freezed,}) {
  return _then(_ModlogState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ModlogStatus,modlogActionType: null == modlogActionType ? _self.modlogActionType : modlogActionType // ignore: cast_nullable_to_non_nullable
as ModlogActionType,communityId: freezed == communityId ? _self.communityId : communityId // ignore: cast_nullable_to_non_nullable
as int?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,moderatorId: freezed == moderatorId ? _self.moderatorId : moderatorId // ignore: cast_nullable_to_non_nullable
as int?,commentId: freezed == commentId ? _self.commentId : commentId // ignore: cast_nullable_to_non_nullable
as int?,modlogEventItems: null == modlogEventItems ? _self.modlogEventItems : modlogEventItems // ignore: cast_nullable_to_non_nullable
as List<ModlogEventItem>,hasReachedEnd: null == hasReachedEnd ? _self.hasReachedEnd : hasReachedEnd // ignore: cast_nullable_to_non_nullable
as bool,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

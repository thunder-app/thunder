// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'modlog_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ModlogState {
  /// The status of the modlog feed.
  ModlogStatus get status => throw _privateConstructorUsedError;

  /// The type of modlog action to filter by.
  ModlogActionType get modlogActionType => throw _privateConstructorUsedError;

  /// A community ID to filter the modlog by.
  int? get communityId => throw _privateConstructorUsedError;

  /// A user ID to filter the modlog by.
  int? get userId => throw _privateConstructorUsedError;

  /// A moderator ID to filter the modlog by.
  int? get moderatorId => throw _privateConstructorUsedError;

  /// A comment ID to filter the modlog by.
  int? get commentId => throw _privateConstructorUsedError;

  /// The list of modlog events.
  List<ModlogEventItem> get modlogEventItems =>
      throw _privateConstructorUsedError;

  /// Whether the end of the modlog has been reached.
  bool get hasReachedEnd => throw _privateConstructorUsedError;

  /// The current page of the modlog.
  int get currentPage => throw _privateConstructorUsedError;

  /// The error message to display after a failure.
  String? get message => throw _privateConstructorUsedError;

  /// Create a copy of ModlogState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModlogStateCopyWith<ModlogState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModlogStateCopyWith<$Res> {
  factory $ModlogStateCopyWith(
          ModlogState value, $Res Function(ModlogState) then) =
      _$ModlogStateCopyWithImpl<$Res, ModlogState>;
  @useResult
  $Res call(
      {ModlogStatus status,
      ModlogActionType modlogActionType,
      int? communityId,
      int? userId,
      int? moderatorId,
      int? commentId,
      List<ModlogEventItem> modlogEventItems,
      bool hasReachedEnd,
      int currentPage,
      String? message});
}

/// @nodoc
class _$ModlogStateCopyWithImpl<$Res, $Val extends ModlogState>
    implements $ModlogStateCopyWith<$Res> {
  _$ModlogStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModlogState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? modlogActionType = null,
    Object? communityId = freezed,
    Object? userId = freezed,
    Object? moderatorId = freezed,
    Object? commentId = freezed,
    Object? modlogEventItems = null,
    Object? hasReachedEnd = null,
    Object? currentPage = null,
    Object? message = freezed,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ModlogStatus,
      modlogActionType: null == modlogActionType
          ? _value.modlogActionType
          : modlogActionType // ignore: cast_nullable_to_non_nullable
              as ModlogActionType,
      communityId: freezed == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as int?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int?,
      moderatorId: freezed == moderatorId
          ? _value.moderatorId
          : moderatorId // ignore: cast_nullable_to_non_nullable
              as int?,
      commentId: freezed == commentId
          ? _value.commentId
          : commentId // ignore: cast_nullable_to_non_nullable
              as int?,
      modlogEventItems: null == modlogEventItems
          ? _value.modlogEventItems
          : modlogEventItems // ignore: cast_nullable_to_non_nullable
              as List<ModlogEventItem>,
      hasReachedEnd: null == hasReachedEnd
          ? _value.hasReachedEnd
          : hasReachedEnd // ignore: cast_nullable_to_non_nullable
              as bool,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ModlogStateImplCopyWith<$Res>
    implements $ModlogStateCopyWith<$Res> {
  factory _$$ModlogStateImplCopyWith(
          _$ModlogStateImpl value, $Res Function(_$ModlogStateImpl) then) =
      __$$ModlogStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ModlogStatus status,
      ModlogActionType modlogActionType,
      int? communityId,
      int? userId,
      int? moderatorId,
      int? commentId,
      List<ModlogEventItem> modlogEventItems,
      bool hasReachedEnd,
      int currentPage,
      String? message});
}

/// @nodoc
class __$$ModlogStateImplCopyWithImpl<$Res>
    extends _$ModlogStateCopyWithImpl<$Res, _$ModlogStateImpl>
    implements _$$ModlogStateImplCopyWith<$Res> {
  __$$ModlogStateImplCopyWithImpl(
      _$ModlogStateImpl _value, $Res Function(_$ModlogStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ModlogState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? modlogActionType = null,
    Object? communityId = freezed,
    Object? userId = freezed,
    Object? moderatorId = freezed,
    Object? commentId = freezed,
    Object? modlogEventItems = null,
    Object? hasReachedEnd = null,
    Object? currentPage = null,
    Object? message = freezed,
  }) {
    return _then(_$ModlogStateImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ModlogStatus,
      modlogActionType: null == modlogActionType
          ? _value.modlogActionType
          : modlogActionType // ignore: cast_nullable_to_non_nullable
              as ModlogActionType,
      communityId: freezed == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as int?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int?,
      moderatorId: freezed == moderatorId
          ? _value.moderatorId
          : moderatorId // ignore: cast_nullable_to_non_nullable
              as int?,
      commentId: freezed == commentId
          ? _value.commentId
          : commentId // ignore: cast_nullable_to_non_nullable
              as int?,
      modlogEventItems: null == modlogEventItems
          ? _value._modlogEventItems
          : modlogEventItems // ignore: cast_nullable_to_non_nullable
              as List<ModlogEventItem>,
      hasReachedEnd: null == hasReachedEnd
          ? _value.hasReachedEnd
          : hasReachedEnd // ignore: cast_nullable_to_non_nullable
              as bool,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ModlogStateImpl extends _ModlogState {
  const _$ModlogStateImpl(
      {this.status = ModlogStatus.initial,
      this.modlogActionType = ModlogActionType.all,
      this.communityId,
      this.userId,
      this.moderatorId,
      this.commentId,
      final List<ModlogEventItem> modlogEventItems = const [],
      this.hasReachedEnd = false,
      this.currentPage = 1,
      this.message})
      : _modlogEventItems = modlogEventItems,
        super._();

  /// The status of the modlog feed.
  @override
  @JsonKey()
  final ModlogStatus status;

  /// The type of modlog action to filter by.
  @override
  @JsonKey()
  final ModlogActionType modlogActionType;

  /// A community ID to filter the modlog by.
  @override
  final int? communityId;

  /// A user ID to filter the modlog by.
  @override
  final int? userId;

  /// A moderator ID to filter the modlog by.
  @override
  final int? moderatorId;

  /// A comment ID to filter the modlog by.
  @override
  final int? commentId;

  /// The list of modlog events.
  final List<ModlogEventItem> _modlogEventItems;

  /// The list of modlog events.
  @override
  @JsonKey()
  List<ModlogEventItem> get modlogEventItems {
    if (_modlogEventItems is EqualUnmodifiableListView)
      return _modlogEventItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_modlogEventItems);
  }

  /// Whether the end of the modlog has been reached.
  @override
  @JsonKey()
  final bool hasReachedEnd;

  /// The current page of the modlog.
  @override
  @JsonKey()
  final int currentPage;

  /// The error message to display after a failure.
  @override
  final String? message;

  @override
  String toString() {
    return 'ModlogState(status: $status, modlogActionType: $modlogActionType, communityId: $communityId, userId: $userId, moderatorId: $moderatorId, commentId: $commentId, modlogEventItems: $modlogEventItems, hasReachedEnd: $hasReachedEnd, currentPage: $currentPage, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModlogStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.modlogActionType, modlogActionType) ||
                other.modlogActionType == modlogActionType) &&
            (identical(other.communityId, communityId) ||
                other.communityId == communityId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.moderatorId, moderatorId) ||
                other.moderatorId == moderatorId) &&
            (identical(other.commentId, commentId) ||
                other.commentId == commentId) &&
            const DeepCollectionEquality()
                .equals(other._modlogEventItems, _modlogEventItems) &&
            (identical(other.hasReachedEnd, hasReachedEnd) ||
                other.hasReachedEnd == hasReachedEnd) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      status,
      modlogActionType,
      communityId,
      userId,
      moderatorId,
      commentId,
      const DeepCollectionEquality().hash(_modlogEventItems),
      hasReachedEnd,
      currentPage,
      message);

  /// Create a copy of ModlogState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModlogStateImplCopyWith<_$ModlogStateImpl> get copyWith =>
      __$$ModlogStateImplCopyWithImpl<_$ModlogStateImpl>(this, _$identity);
}

abstract class _ModlogState extends ModlogState {
  const factory _ModlogState(
      {final ModlogStatus status,
      final ModlogActionType modlogActionType,
      final int? communityId,
      final int? userId,
      final int? moderatorId,
      final int? commentId,
      final List<ModlogEventItem> modlogEventItems,
      final bool hasReachedEnd,
      final int currentPage,
      final String? message}) = _$ModlogStateImpl;
  const _ModlogState._() : super._();

  /// The status of the modlog feed.
  @override
  ModlogStatus get status;

  /// The type of modlog action to filter by.
  @override
  ModlogActionType get modlogActionType;

  /// A community ID to filter the modlog by.
  @override
  int? get communityId;

  /// A user ID to filter the modlog by.
  @override
  int? get userId;

  /// A moderator ID to filter the modlog by.
  @override
  int? get moderatorId;

  /// A comment ID to filter the modlog by.
  @override
  int? get commentId;

  /// The list of modlog events.
  @override
  List<ModlogEventItem> get modlogEventItems;

  /// Whether the end of the modlog has been reached.
  @override
  bool get hasReachedEnd;

  /// The current page of the modlog.
  @override
  int get currentPage;

  /// The error message to display after a failure.
  @override
  String? get message;

  /// Create a copy of ModlogState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModlogStateImplCopyWith<_$ModlogStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

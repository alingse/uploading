// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Item _$ItemFromJson(Map<String, dynamic> json) {
  return _Item.fromJson(json);
}

/// @nodoc
mixin _$Item {
  /// 唯一标识
  String get id => throw _privateConstructorUsedError;

  /// 照片列表
  List<Photo> get photos => throw _privateConstructorUsedError;

  /// 存在性（实物保留/电子永生/待决策）
  Presence get presence => throw _privateConstructorUsedError;

  /// 文字备注
  String? get notes => throw _privateConstructorUsedError;

  /// 标签列表
  List<String> get tags => throw _privateConstructorUsedError;

  /// 创建时间
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// 时间事件列表（灵活的时间节点记录）
  List<TimeEvent> get timeEvents => throw _privateConstructorUsedError;

  /// 最后同步时间（可选）
  DateTime? get lastSyncedAt => throw _privateConstructorUsedError;

  /// Serializes this Item to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Item
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ItemCopyWith<Item> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ItemCopyWith<$Res> {
  factory $ItemCopyWith(Item value, $Res Function(Item) then) =
      _$ItemCopyWithImpl<$Res, Item>;
  @useResult
  $Res call(
      {String id,
      List<Photo> photos,
      Presence presence,
      String? notes,
      List<String> tags,
      DateTime createdAt,
      List<TimeEvent> timeEvents,
      DateTime? lastSyncedAt});
}

/// @nodoc
class _$ItemCopyWithImpl<$Res, $Val extends Item>
    implements $ItemCopyWith<$Res> {
  _$ItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Item
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? photos = null,
    Object? presence = null,
    Object? notes = freezed,
    Object? tags = null,
    Object? createdAt = null,
    Object? timeEvents = null,
    Object? lastSyncedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      photos: null == photos
          ? _value.photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<Photo>,
      presence: null == presence
          ? _value.presence
          : presence // ignore: cast_nullable_to_non_nullable
              as Presence,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      timeEvents: null == timeEvents
          ? _value.timeEvents
          : timeEvents // ignore: cast_nullable_to_non_nullable
              as List<TimeEvent>,
      lastSyncedAt: freezed == lastSyncedAt
          ? _value.lastSyncedAt
          : lastSyncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ItemImplCopyWith<$Res> implements $ItemCopyWith<$Res> {
  factory _$$ItemImplCopyWith(
          _$ItemImpl value, $Res Function(_$ItemImpl) then) =
      __$$ItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      List<Photo> photos,
      Presence presence,
      String? notes,
      List<String> tags,
      DateTime createdAt,
      List<TimeEvent> timeEvents,
      DateTime? lastSyncedAt});
}

/// @nodoc
class __$$ItemImplCopyWithImpl<$Res>
    extends _$ItemCopyWithImpl<$Res, _$ItemImpl>
    implements _$$ItemImplCopyWith<$Res> {
  __$$ItemImplCopyWithImpl(_$ItemImpl _value, $Res Function(_$ItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of Item
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? photos = null,
    Object? presence = null,
    Object? notes = freezed,
    Object? tags = null,
    Object? createdAt = null,
    Object? timeEvents = null,
    Object? lastSyncedAt = freezed,
  }) {
    return _then(_$ItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      photos: null == photos
          ? _value._photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<Photo>,
      presence: null == presence
          ? _value.presence
          : presence // ignore: cast_nullable_to_non_nullable
              as Presence,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      timeEvents: null == timeEvents
          ? _value._timeEvents
          : timeEvents // ignore: cast_nullable_to_non_nullable
              as List<TimeEvent>,
      lastSyncedAt: freezed == lastSyncedAt
          ? _value.lastSyncedAt
          : lastSyncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ItemImpl implements _Item {
  const _$ItemImpl(
      {required this.id,
      required final List<Photo> photos,
      required this.presence,
      this.notes,
      final List<String> tags = const [],
      required this.createdAt,
      final List<TimeEvent> timeEvents = const [],
      this.lastSyncedAt})
      : _photos = photos,
        _tags = tags,
        _timeEvents = timeEvents;

  factory _$ItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ItemImplFromJson(json);

  /// 唯一标识
  @override
  final String id;

  /// 照片列表
  final List<Photo> _photos;

  /// 照片列表
  @override
  List<Photo> get photos {
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photos);
  }

  /// 存在性（实物保留/电子永生/待决策）
  @override
  final Presence presence;

  /// 文字备注
  @override
  final String? notes;

  /// 标签列表
  final List<String> _tags;

  /// 标签列表
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  /// 创建时间
  @override
  final DateTime createdAt;

  /// 时间事件列表（灵活的时间节点记录）
  final List<TimeEvent> _timeEvents;

  /// 时间事件列表（灵活的时间节点记录）
  @override
  @JsonKey()
  List<TimeEvent> get timeEvents {
    if (_timeEvents is EqualUnmodifiableListView) return _timeEvents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_timeEvents);
  }

  /// 最后同步时间（可选）
  @override
  final DateTime? lastSyncedAt;

  @override
  String toString() {
    return 'Item(id: $id, photos: $photos, presence: $presence, notes: $notes, tags: $tags, createdAt: $createdAt, timeEvents: $timeEvents, lastSyncedAt: $lastSyncedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other._photos, _photos) &&
            (identical(other.presence, presence) ||
                other.presence == presence) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality()
                .equals(other._timeEvents, _timeEvents) &&
            (identical(other.lastSyncedAt, lastSyncedAt) ||
                other.lastSyncedAt == lastSyncedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      const DeepCollectionEquality().hash(_photos),
      presence,
      notes,
      const DeepCollectionEquality().hash(_tags),
      createdAt,
      const DeepCollectionEquality().hash(_timeEvents),
      lastSyncedAt);

  /// Create a copy of Item
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ItemImplCopyWith<_$ItemImpl> get copyWith =>
      __$$ItemImplCopyWithImpl<_$ItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ItemImplToJson(
      this,
    );
  }
}

abstract class _Item implements Item {
  const factory _Item(
      {required final String id,
      required final List<Photo> photos,
      required final Presence presence,
      final String? notes,
      final List<String> tags,
      required final DateTime createdAt,
      final List<TimeEvent> timeEvents,
      final DateTime? lastSyncedAt}) = _$ItemImpl;

  factory _Item.fromJson(Map<String, dynamic> json) = _$ItemImpl.fromJson;

  /// 唯一标识
  @override
  String get id;

  /// 照片列表
  @override
  List<Photo> get photos;

  /// 存在性（实物保留/电子永生/待决策）
  @override
  Presence get presence;

  /// 文字备注
  @override
  String? get notes;

  /// 标签列表
  @override
  List<String> get tags;

  /// 创建时间
  @override
  DateTime get createdAt;

  /// 时间事件列表（灵活的时间节点记录）
  @override
  List<TimeEvent> get timeEvents;

  /// 最后同步时间（可选）
  @override
  DateTime? get lastSyncedAt;

  /// Create a copy of Item
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ItemImplCopyWith<_$ItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

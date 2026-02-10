// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'time_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TimeEvent _$TimeEventFromJson(Map<String, dynamic> json) {
  return _TimeEvent.fromJson(json);
}

/// @nodoc
mixin _$TimeEvent {
  /// 唯一标识
  String get id => throw _privateConstructorUsedError;

  /// 自定义标签（如"买入"、"谁送的"、"制作时间"、"打包"等）
  String get label => throw _privateConstructorUsedError;

  /// 日期时间（格式：YYYY-MM-DD 或 YYYY-MM-DD HH:MM）
  String get datetime => throw _privateConstructorUsedError;

  /// 对应的值（如价格、人名等，可为空）
  String get value => throw _privateConstructorUsedError;

  /// 详细描述（可选）
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this TimeEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimeEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimeEventCopyWith<TimeEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeEventCopyWith<$Res> {
  factory $TimeEventCopyWith(TimeEvent value, $Res Function(TimeEvent) then) =
      _$TimeEventCopyWithImpl<$Res, TimeEvent>;
  @useResult
  $Res call(
      {String id,
      String label,
      String datetime,
      String value,
      String? description});
}

/// @nodoc
class _$TimeEventCopyWithImpl<$Res, $Val extends TimeEvent>
    implements $TimeEventCopyWith<$Res> {
  _$TimeEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimeEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? datetime = null,
    Object? value = null,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      datetime: null == datetime
          ? _value.datetime
          : datetime // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimeEventImplCopyWith<$Res>
    implements $TimeEventCopyWith<$Res> {
  factory _$$TimeEventImplCopyWith(
          _$TimeEventImpl value, $Res Function(_$TimeEventImpl) then) =
      __$$TimeEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String label,
      String datetime,
      String value,
      String? description});
}

/// @nodoc
class __$$TimeEventImplCopyWithImpl<$Res>
    extends _$TimeEventCopyWithImpl<$Res, _$TimeEventImpl>
    implements _$$TimeEventImplCopyWith<$Res> {
  __$$TimeEventImplCopyWithImpl(
      _$TimeEventImpl _value, $Res Function(_$TimeEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of TimeEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? datetime = null,
    Object? value = null,
    Object? description = freezed,
  }) {
    return _then(_$TimeEventImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      datetime: null == datetime
          ? _value.datetime
          : datetime // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeEventImpl implements _TimeEvent {
  const _$TimeEventImpl(
      {required this.id,
      required this.label,
      required this.datetime,
      this.value = '',
      this.description});

  factory _$TimeEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeEventImplFromJson(json);

  /// 唯一标识
  @override
  final String id;

  /// 自定义标签（如"买入"、"谁送的"、"制作时间"、"打包"等）
  @override
  final String label;

  /// 日期时间（格式：YYYY-MM-DD 或 YYYY-MM-DD HH:MM）
  @override
  final String datetime;

  /// 对应的值（如价格、人名等，可为空）
  @override
  @JsonKey()
  final String value;

  /// 详细描述（可选）
  @override
  final String? description;

  @override
  String toString() {
    return 'TimeEvent(id: $id, label: $label, datetime: $datetime, value: $value, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.datetime, datetime) ||
                other.datetime == datetime) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, label, datetime, value, description);

  /// Create a copy of TimeEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeEventImplCopyWith<_$TimeEventImpl> get copyWith =>
      __$$TimeEventImplCopyWithImpl<_$TimeEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeEventImplToJson(
      this,
    );
  }
}

abstract class _TimeEvent implements TimeEvent {
  const factory _TimeEvent(
      {required final String id,
      required final String label,
      required final String datetime,
      final String value,
      final String? description}) = _$TimeEventImpl;

  factory _TimeEvent.fromJson(Map<String, dynamic> json) =
      _$TimeEventImpl.fromJson;

  /// 唯一标识
  @override
  String get id;

  /// 自定义标签（如"买入"、"谁送的"、"制作时间"、"打包"等）
  @override
  String get label;

  /// 日期时间（格式：YYYY-MM-DD 或 YYYY-MM-DD HH:MM）
  @override
  String get datetime;

  /// 对应的值（如价格、人名等，可为空）
  @override
  String get value;

  /// 详细描述（可选）
  @override
  String? get description;

  /// Create a copy of TimeEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeEventImplCopyWith<_$TimeEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

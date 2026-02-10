// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TimeEventImpl _$$TimeEventImplFromJson(Map<String, dynamic> json) =>
    _$TimeEventImpl(
      id: json['id'] as String,
      label: json['label'] as String,
      datetime: json['datetime'] as String,
      value: json['value'] as String? ?? '',
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$TimeEventImplToJson(_$TimeEventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'datetime': instance.datetime,
      'value': instance.value,
      'description': instance.description,
    };

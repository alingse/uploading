// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ItemImpl _$$ItemImplFromJson(Map<String, dynamic> json) => _$ItemImpl(
      id: json['id'] as String,
      photos: (json['photos'] as List<dynamic>)
          .map((e) => Photo.fromJson(e as Map<String, dynamic>))
          .toList(),
      presence: $enumDecode(_$PresenceEnumMap, json['presence']),
      notes: json['notes'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      timeEvents: (json['timeEvents'] as List<dynamic>?)
              ?.map((e) => TimeEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      lastSyncedAt: json['lastSyncedAt'] == null
          ? null
          : DateTime.parse(json['lastSyncedAt'] as String),
    );

Map<String, dynamic> _$$ItemImplToJson(_$ItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'photos': instance.photos,
      'presence': _$PresenceEnumMap[instance.presence]!,
      'notes': instance.notes,
      'tags': instance.tags,
      'createdAt': instance.createdAt.toIso8601String(),
      'timeEvents': instance.timeEvents,
      'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
    };

const _$PresenceEnumMap = {
  Presence.physical: 'physical',
  Presence.electronic: 'electronic',
  Presence.pending: 'pending',
};

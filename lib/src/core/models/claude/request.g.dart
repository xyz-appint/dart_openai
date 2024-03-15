// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClaudeMessage _$MessageFromJson(Map<String, dynamic> json) => ClaudeMessage(
      role: json['role'] as String?,
      content: json['content'] as String?,
    );

Map<String, dynamic> _$MessageToJson(ClaudeMessage instance) =>
    <String, dynamic>{
      'role': instance.role,
      'content': instance.content,
    };

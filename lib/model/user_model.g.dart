// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      json['name'] as String,
      (json['requests'] as List<dynamic>).map((e) => e as String).toList(),
      (json['invites'] as List<dynamic>).map((e) => e as String).toList(),
      (json['friends'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'name': instance.name,
      'requests': instance.requests,
      'invites': instance.invites,
      'friends': instance.friends,
    };

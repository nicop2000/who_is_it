// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'picture.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Picture _$PictureFromJson(Map<String, dynamic> json) => Picture(
      filename: json['filename'] as String,
      category: Category.fromJson(json['category'] as Map<String, dynamic>),
      name: json['name'] as String,
      attributes: (json['attributes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$PictureToJson(Picture instance) => <String, dynamic>{
      'filename': instance.filename,
      'name': instance.name,
      'category': instance.category.toJson(),
      'attributes': instance.attributes,
      'opacity': instance.opacity,
    };

import 'package:json_annotation/json_annotation.dart';
import 'package:who_is_it/model/category.dart';

part 'picture.g.dart';

@JsonSerializable()
class Picture {

  String filename;
  Category category;
  List<String>? attributes;
  double opacity;

  Picture({required this.filename, required this.category, this.attributes, this.opacity = 1.0});

  factory Picture.fromJson(Map<String, dynamic> json) =>
      _$PictureFromJson(json);

  Map<String, dynamic> toJson() => _$PictureToJson(this);
}

//flutter pub run build_runner build
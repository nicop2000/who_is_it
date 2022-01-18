import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:who_is_it/model/category.dart';

part 'picture.g.dart';

@JsonSerializable()
class Picture {

  String filename;
  String name;
  Category category;
  List<String>? attributes;
  double opacity;
  @JsonKey(ignore: true)
  Image? image;

  Picture({required this.filename, required this.category, required this.name, this.attributes, this.opacity = 1.0, this.image});

  factory Picture.fromJson(Map<String, dynamic> json) =>
      _$PictureFromJson(json);

  Map<String, dynamic> toJson() => _$PictureToJson(this);

  String getLink() => "${category.name.toLowerCase().replaceAll(" ", "-")}/${filename.toLowerCase().replaceAll(" ", "-")}";

  void changeOpacity() {
    if (opacity == 1.0) {
      opacity = 0.03;
    } else {
      opacity = 1.0;
    }
  }
  
  Future<bool> buildImage() async {
    String link = getLink();
    image = Image.network(await FirebaseStorage.instance.ref().child(link).getDownloadURL());
    return true;
  }




  
  
}

//flutter pub run build_runner build
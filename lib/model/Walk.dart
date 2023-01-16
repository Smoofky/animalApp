import 'dart:convert';

import 'package:flutter/foundation.dart';

class Walk {
  int? id;
  int? coins;
  String? time;
  double? distance;
  List<dynamic>? photo;
  List<dynamic>? animalIdList;

  Walk({
    this.id,
    this.coins,
    this.time,
    this.distance,
    this.animalIdList,
    this.photo,
  });

  factory Walk.fromJson(Map json) {
    return Walk(
      id: json['id'],
      time: json['time'],
      distance: json['distance'],
      coins: json['coins_gained'],
      animalIdList: json['animals_id'],
      photo: json['photo'],
    );
  }

  Map toMap() {
    var map = {};
    //map["id"] = "string";
    map["time"] = time;
    map["distance"] = distance;
    map["coins_gained"] = coins;
    map["animals_id"] = animalIdList;
    map["photo"] = photo;
    return map;
  }
}

import 'dart:convert';

class Animal {
  int? id;
  String? name;
  String? birthDate;
  String? kind;
  double? height;
  String? bio;
  String? sex;
  double? weight;
  String? photo;
  // Pin pins;
  int? breed;

  Animal(
      {this.id,
      this.name,
      this.bio,
      this.birthDate,
      this.sex,
      this.weight,
      this.photo,
      this.height,
      this.kind,
      this.breed});

  factory Animal.fromJson(Map json) {
    return Animal(
        id: json['id'],
        name: json['name'],
        bio: json['bio'],
        birthDate: json['birth_date'],
        sex: json['sex'],
        weight: json['weight'],
        photo: json['photo_url'],
        height: json['height'],
        kind: json['kind'],
        breed: json['breed_id']);
  }

  Map toMap() {
    var map = {};
    //map["id"] = "string";
    map["name"] = name;
    map["bio"] = bio;
    map["birth_date"] = birthDate;
    map["sex"] = sex;
    map["weight"] = weight;
    map["photo"] = photo;
    map["height"] = height;
    map["kind"] = kind;
    map["breed_id"] = breed;

    return map;
  }

/*
  Map toMapAdd() {
    var map = {};
    map["email"] = email;
    map["password"] = password;
    return map;
  }*/
}

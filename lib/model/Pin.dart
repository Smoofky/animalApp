
class Pin {
  String? name;
  String? description;
  double? latitude, longtitude;
  int? animalId;
  Pin(
      {this.animalId,
      this.description,
      this.latitude,
      this.longtitude,
      this.name});

  factory Pin.fromJson(Map json) {
    return Pin(
      name: json['name'],
      latitude: json['latitude'],
      longtitude: json['longtitude'],
      description: json['description'],
      animalId: json['animal_id'],
    );
  }

  Map toMap() {
    var map = {};
    map["name"] = name;
    map["latitude"] = latitude;
    map["longtitude"] = longtitude;
    map["description"] = description;
    map["animal_id"] = animalId;
    return map;
  }
}

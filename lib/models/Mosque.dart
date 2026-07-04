// lib/models/Mosque.dart

class Mosque {
  int? id;
  String name;
  double lat;
  double lon;

  Mosque({
    this.id,
    required this.name,
    required this.lat,
    required this.lon,
  });

  // Convert from DB map → object
  factory Mosque.fromMap(Map<String, dynamic> json) {
    return Mosque(
      id: json['id'],
      name: json['name'],
      lat: json['lat'],
      lon: json['lon'],
    );
  }

  // Convert object → DB map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lon': lon,
    };
  }
}

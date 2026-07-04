// lib/models/Location.dart
// This import seems unnecessary for this class.

class Location {
  int? id;
  String name;
  int preAlarmMinutes;
  double latitude;
  double longitude;
  double diameter;

  Location({
    this.id,
    required this.name,
    this.preAlarmMinutes = 0,
    this.latitude = 0,
    this.longitude = 0,
    this.diameter = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'preAlarmMinutes': preAlarmMinutes,
      'latitude': latitude, // Added
      'longitude': longitude, // Added
      'diameter': diameter, // Added
    };
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id'],
      name: map['name'],
      preAlarmMinutes: map['preAlarmMinutes'] ?? 0,
      latitude: map['latitude'] ?? 0.0, // Added with null-check
      longitude: map['longitude'] ?? 0.0, // Added with null-check
      diameter: map['diameter'] ?? 0.0, // Added with null-check
    );
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      preAlarmMinutes.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      diameter.hashCode; // All fields included

  @override
  String toString() {
    return 'Location{id: $id, name: $name, preAlarmMinutes: $preAlarmMinutes, latitude: $latitude, longitude: $longitude, diameter: $diameter}'; // All fields included
  }
}

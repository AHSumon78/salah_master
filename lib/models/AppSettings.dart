// lib/models/AppSettings.dart

class AppSettings {
  final int id; // 'final' is good for properties that shouldn't change after creation
  int currentLocationId;
  String currentLocation;
  bool enable;

  AppSettings({
    this.id = 1, // Default ID to 1 as there should be only one settings row
    required this.currentLocation,
    required this.currentLocationId,
    required this.enable,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'currentLocation': currentLocation,
      'currentLocationId': currentLocationId,
      'enable': enable ? 1 : 0,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      id: map['id'] as int? ?? 1,
      currentLocation: map['currentLocation'] as String,
      currentLocationId: map['currentLocationId'] as int? ?? 0,
      enable: (map['enable'] as int? ?? 0) == 1,
    );
  }

  @override
  int get hashCode =>
      id.hashCode ^
      currentLocation.hashCode ^
      currentLocationId.hashCode ^
      enable.hashCode;

  @override
  String toString() {
    return 'AppSettings{id: $id, currentLocationId: $currentLocationId, currentLocation: $currentLocation, enable: $enable}';
  }
}

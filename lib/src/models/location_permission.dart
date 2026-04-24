/// Represents location permission status.
enum LocationPermission {
  /// Permission denied.
  denied,

  /// Permission denied forever (user selected "Don't ask again").
  deniedForever,

  /// Permission granted while in use (foreground only).
  whileInUse,

  /// Permission granted always (foreground and background).
  always,

  /// Permission status is unknown.
  unknown,
}

/// Extension for LocationPermission with helper methods.
extension LocationPermissionExtension on LocationPermission {
  /// Returns true if permission is granted.
  bool get isGranted =>
      this == LocationPermission.whileInUse ||
      this == LocationPermission.always;

  /// Returns true if permission is denied.
  bool get isDenied =>
      this == LocationPermission.denied || this == LocationPermission.deniedForever;

  /// Returns true if permission is permanently denied.
  bool get isPermanentlyDenied => this == LocationPermission.deniedForever;
}

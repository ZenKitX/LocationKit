/// Location error types.
enum LocationErrorType {
  /// Permission denied by user.
  permissionDenied,

  /// Permission permanently denied (user selected "Don't ask again").
  permissionPermanentlyDenied,

  /// Location service is disabled on device.
  serviceDisabled,

  /// Location request timed out.
  timeout,

  /// Unknown error occurred.
  unknown,
}

/// Represents a location-related error.
class LocationError {
  LocationError._(this.type, this.message);

  /// Create a permission denied error.
  factory LocationError.permissionDenied(String message) {
    return LocationError._(LocationErrorType.permissionDenied, message);
  }

  /// Create a permanently denied error.
  factory LocationError.permissionPermanentlyDenied(String message) {
    return LocationError._(
      LocationErrorType.permissionPermanentlyDenied,
      message,
    );
  }

  /// Create a service disabled error.
  factory LocationError.serviceDisabled(String message) {
    return LocationError._(LocationErrorType.serviceDisabled, message);
  }

  /// Create a timeout error.
  factory LocationError.timeout(String message) {
    return LocationError._(LocationErrorType.timeout, message);
  }

  /// Create an unknown error.
  factory LocationError.unknown(String message) {
    return LocationError._(LocationErrorType.unknown, message);
  }

  /// The type of error.
  final LocationErrorType type;

  /// Error message.
  final String message;

  @override
  String toString() => 'LocationError($type: $message)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LocationError &&
        other.type == type &&
        other.message == message;
  }

  @override
  int get hashCode => type.hashCode ^ message.hashCode;
}

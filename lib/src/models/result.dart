/// Result type for operations that can fail.
///
/// Either contains a success value of type [T] or an error.
class Result<T> {
  const Result._({
    required this.isSuccess,
    required this.isFailure,
    this.data,
    this.error,
  });

  /// Create a success result with data.
  const Result.success(T data)
      : data = data,
        error = null,
        isSuccess = true,
        isFailure = false;

  /// Create a failure result with an error.
  const Result.failure(LocationError error)
      : data = null,
        error = error,
        isSuccess = false,
        isFailure = true;

  /// True if the result is successful.
  final bool isSuccess;

  /// True if the result is a failure.
  final bool isFailure;

  /// The success data (null if failure).
  final T? data;

  /// The error (null if success).
  final LocationError? error;

  /// Transform the data if successful, otherwise keep the error.
  Result<R> map<R>(R Function(T data) mapper) {
    if (isSuccess && data != null) {
      return Result.success(mapper(data));
    }
    return Result.failure(error!);
  }

  /// Apply a function to the data or handle the error.
  R fold<R>(R Function(T data) onSuccess, R Function(LocationError error) onError) {
    if (isSuccess && data != null) {
      return onSuccess(data);
    }
    return onError(error!);
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'Result.success($data)';
    } else {
      return 'Result.failure($error)';
    }
  }
}

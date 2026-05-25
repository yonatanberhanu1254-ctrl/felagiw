/// Thrown when a server/Firebase call fails.
class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server error occurred.']);
}

/// Thrown when there is no network connectivity.
class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection.']);
}

/// Thrown on Firebase Auth errors.
class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Authentication error.']);
}

/// Thrown on local cache read/write errors.
class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error.']);
}

/// Thrown when a resource is not found.
class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Not found.']);
}

/// Thrown when file storage operations fail.
class StorageException implements Exception {
  final String message;
  const StorageException([this.message = 'Storage error.']);
}

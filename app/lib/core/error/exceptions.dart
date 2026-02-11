class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server error occurred']);
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Authentication failed']);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error occurred']);
}

class StorageException implements Exception {
  final String message;
  const StorageException([this.message = 'Storage error occurred']);
}

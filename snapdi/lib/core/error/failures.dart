abstract class Failure {
  final String message;
  final int? code;

  const Failure(this.message, [this.code]);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && other.message == message && other.code == code;
  }

  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}

// Server Failures
class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.code]);
}

// Network Failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.code]);
}

// Cache Failures
class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.code]);
}

// Validation Failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.code]);
}

// Authentication Failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message, [super.code]);
}

// Authorization Failures
class AuthorizationFailure extends Failure {
  const AuthorizationFailure(super.message, [super.code]);
}

// Not Found Failures
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, [super.code]);
}

// Timeout Failures
class TimeoutFailure extends Failure {
  const TimeoutFailure(super.message, [super.code]);
}

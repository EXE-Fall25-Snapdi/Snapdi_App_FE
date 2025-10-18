import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthToken>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthToken>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    required UserRole role,
  });

  Future<Either<Failure, AuthToken>> refreshToken({
    required String refreshToken,
  });

  Future<Either<Failure, Unit>> logout();

  Future<Either<Failure, User>> getCurrentUser();

  Future<Either<Failure, Unit>> forgotPassword({required String email});

  Future<Either<Failure, Unit>> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<Either<Failure, Unit>> verifyEmail({required String token});

  Future<Either<Failure, Unit>> resendEmailVerification();

  Future<bool> isLoggedIn();

  Future<AuthToken?> getStoredToken();

  Future<User?> getStoredUser();
}

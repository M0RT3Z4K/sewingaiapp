import 'package:sewingaiapp/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<void> sendOtp(String phone);
  Future<bool> verifyOtp(String phone, String code);
  Future<User> loginOrSignup(String phone);
  Future<void> saveToken(String token);
  Future<String?> getCachedToken();
  Future<User> getUserWithToken(String token);
  Future<void> logout();
}

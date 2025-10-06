import 'package:sewingaiapp/features/auth/domain/repositories/auth_repository.dart';

class VerifyOtp {
  final AuthRepository repository;
  VerifyOtp(this.repository);

  Future<bool> call(String phone, String code) =>
      repository.verifyOtp(phone, code);
}

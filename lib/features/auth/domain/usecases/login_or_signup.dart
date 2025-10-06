import 'package:sewingaiapp/features/auth/domain/entities/user.dart';
import 'package:sewingaiapp/features/auth/domain/repositories/auth_repository.dart';

class LoginOrSignup {
  final AuthRepository repository;
  LoginOrSignup(this.repository);

  Future<User> call(String phone) => repository.loginOrSignup(phone);
}

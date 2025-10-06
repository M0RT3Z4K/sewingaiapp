import 'package:sewingaiapp/features/auth/domain/entities/user.dart';
import 'package:sewingaiapp/features/auth/domain/repositories/auth_repository.dart';

class GetUserWithToken {
  final AuthRepository repository;
  GetUserWithToken(this.repository);

  Future<User> call(String token) => repository.getUserWithToken(token);
}

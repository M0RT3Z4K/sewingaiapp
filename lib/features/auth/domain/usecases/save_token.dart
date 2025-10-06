import 'package:sewingaiapp/features/auth/domain/repositories/auth_repository.dart';

class SaveToken {
  final AuthRepository repository;
  SaveToken(this.repository);

  Future<void> call(String token) => repository.saveToken(token);
}

import 'package:sewingaiapp/features/auth/domain/repositories/auth_repository.dart';

class GetCachedToken {
  final AuthRepository repository;
  GetCachedToken(this.repository);

  Future<String?> call() => repository.getCachedToken();
}

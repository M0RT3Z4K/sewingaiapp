import 'package:sewingaiapp/features/auth/domain/entities/user.dart';
import 'package:sewingaiapp/features/chat/domain/repositories/chat_repository.dart';

class GetCurrentUser {
  final ChatRepository repository;

  GetCurrentUser(this.repository);

  Future<User> call() async {
    return await repository.getCurrentUser();
  }
}

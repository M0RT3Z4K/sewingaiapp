import 'package:get_it/get_it.dart';
import 'package:sewingaiapp/core/network/api_client.dart';
import 'package:sewingaiapp/features/chat/data/models/message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sewingaiapp/features/auth/domain/entities/user.dart' as auth;

abstract class ChatRemoteDataSource {
  Future<MessageModel> sendPrompt(String prompt, List lastMessages);
  Future<MessageModel> sendImgPrompt(
    String prompt,
    List lastMessages,
    String image,
  );
  Future<auth.User> getCurrentUser();
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient client;
  final SupabaseClient supabaseClient;

  ChatRemoteDataSourceImpl(this.client, this.supabaseClient);

  @override
  Future<MessageModel> sendPrompt(String prompt, List lastMessages) async {
    String conversation = '';
    for (var msg in lastMessages) {
      conversation += (msg.isFromUser ? 'User: ' : 'AI: ') + msg.text + '\n';
    }
    final response = await client.post(
      '/chat/completions',
      data: {
        'prompt':
            '''
Respond to the users current message: 
"$conversation"

CURRENT QUESTION: "$prompt"
''',
      },
    );

    final data = response.data as Map<String, dynamic>;
    return MessageModel.fromJson({
      'id': data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'text': data['choices'][0]['message']['content'] ?? '',
      'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
      'isFromUser': false,
      'isLoading': false,
    });
  }

  @override
  Future<MessageModel> sendImgPrompt(
    String prompt,
    List lastMessages,
    String image,
  ) async {
    final user = await getCurrentUser();

    await supabaseClient
        .from('users')
        .update({'image_inday': user.imageInDay + 1})
        .eq('token', user.token)
        .select();

    String conversation = '';
    for (var msg in lastMessages) {
      conversation += (msg.isFromUser ? 'User: ' : 'AI: ') + msg.text + '\n';
    }
    final response = await client.post(
      '/chat/completions',
      data: {
        'prompt':
            '''
Respond to the users current message: 
"$conversation"

CURRENT QUESTION: "$prompt"
''',
        'base64image': image,
      },
    );

    final data = response.data as Map<String, dynamic>;

    return MessageModel.fromJson({
      'id': data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'text': data['choices'][0]['message']['content'] ?? '',
      'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
      'isFromUser': false,
      'isLoading': false,
    });
  }

  @override
  Future<auth.User> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    final user_response = await supabaseClient
        .from('users')
        .select()
        .eq('token', token ?? '')
        .single();

    auth.User user = auth.User.fromJson(user_response);

    if (GetIt.instance.isRegistered<auth.User>()) {
      GetIt.instance.unregister<auth.User>();
    }

    GetIt.instance.registerSingleton<auth.User>(user);
    return user;
  }
}

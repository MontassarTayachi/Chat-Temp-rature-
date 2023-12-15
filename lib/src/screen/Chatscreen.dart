import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatGPTWidget extends StatefulWidget {
  const ChatGPTWidget({Key? key, required this.Donner, required this.Donner2})
      : super(key: key);

  final Map<String, dynamic>? Donner;
  final Map<String, dynamic>? Donner2;
  @override
  _ChatGPTWidgetState createState() => _ChatGPTWidgetState();
}

class _ChatGPTWidgetState extends State<ChatGPTWidget> {
  final String apiKey = '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';
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';

  TextEditingController userMessageController = TextEditingController();
  List<Map<String, String>> chatMessages = [];
  bool isWaitingForResponse = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('     Chat Temperature'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: chatMessages.length,
                itemBuilder: (context, index) {
                  final message = chatMessages[index];
                  return MessageBubble(
                    role: message['role'] ?? '',
                    content: message['content'] ?? '',
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: userMessageController,
                    decoration: InputDecoration(labelText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: isWaitingForResponse ? null : sendMessage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String fixSpecialCharacters(String text) {
    // Convertir le texte encodé en Latin-1 en UTF-8
    final latin1Codec = Latin1Codec();
    final latin1Bytes = latin1Codec.encode(text);
    final fixedText = utf8.decode(latin1Bytes);

    return fixedText;
  }

  Future<void> sendMessage() async {
    if (isWaitingForResponse) {
      // L'utilisateur doit attendre la réponse du robot avant d'envoyer un nouveau message
      return;
    }

    final String userMessage = userMessageController.text;

    if (userMessage.isNotEmpty) {
      try {
        // Définir isWaitingForResponse à true pour bloquer les nouveaux messages
        setState(() {
          isWaitingForResponse = true;
        });

        final http.Response response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': 'gpt-3.5-turbo',
            'messages': [
              {
                'role': 'assistant',
                'content': '''
                     Weather information ${widget.Donner}
                     heur de priere ${widget.Donner2}
      ''',
              },
              {'role': 'user', 'content': userMessage},
            ],
          }),
        );
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          final dynamic assistantChoices = responseData['choices'];

          if (assistantChoices != null && assistantChoices.isNotEmpty) {
            final String assistantMessage =
                fixSpecialCharacters(assistantChoices[0]['message']['content']);

            setState(() {
              chatMessages.add({'role': 'user', 'content': userMessage});
              chatMessages
                  .add({'role': 'assistant', 'content': assistantMessage});
            });

            userMessageController.clear();
          } else {
            print(
                'Error: Empty or missing "choices" array in the API response');
          }
        } else {
          throw Exception(
              'Failed to fetch response. Status code: ${response.statusCode}');
        }
      } catch (error) {
        print('Error: $error');
      } finally {
        // Réinitialiser isWaitingForResponse à false après avoir reçu la réponse ou en cas d'erreur
        setState(() {
          isWaitingForResponse = false;
        });
      }
    }
  }
}

class MessageBubble extends StatelessWidget {
  final String role;
  final String content;

  MessageBubble({required this.role, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Align(
        alignment:
            role == 'user' ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: role == 'user' ? Colors.blue : Colors.green,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            content,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

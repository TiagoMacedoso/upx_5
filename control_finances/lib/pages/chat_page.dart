// lib/pages/chat_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  final int usuarioId;
  const ChatPage({Key? key, required this.usuarioId}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _messages = <Map<String, String>>[];
  bool _sending = false;

  Future<void> _send() async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _messages.insert(0, {"role": "user", "text": q});
      _sending = true;
      _controller.clear();
    });
    try {
      final resp = await http.post(
        Uri.parse('http://192.168.3.19:3000/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "usuario_id": widget.usuarioId,
          "pergunta": q, // certifique-se de usar 'pergunta' (alias mapeado na API)
        }),
      );
      if (resp.statusCode == 200) {
        final responseData = jsonDecode(resp.body);
        final String? answer = responseData['resposta'];
        setState(() {
          _messages.insert(0, {
            "role": "bot",
            "text": answer ?? "Não foi possível obter uma resposta."
          });
          _sending = false;
        });
      } else {
        setState(() {
          _messages.insert(0, {
            "role": "bot",
            "text": "Erro: ${resp.statusCode} - ${resp.body}"
          });
          _sending = false;
        });
      }
    } catch (e) {
      setState(() {
        _messages.insert(0, {
          "role": "bot",
          "text": "Erro de conexão: $e"
        });
        _sending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          'Chat de Suporte',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text('Pergunte algo!'))
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final m = _messages[i];
                      final isUser = m['role'] == 'user';
                      return Align(
                        alignment:
                            isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Colors.blue.shade100
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            m['text']!,
                            style: TextStyle(
                              color: isUser ? Colors.black : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_sending) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Digite sua pergunta',
                    ),
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    autocorrect: true,
                    enableSuggestions: true,
                    onSubmitted: (_) => _send(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sending ? null : _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

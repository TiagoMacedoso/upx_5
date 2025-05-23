import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:control_finances/pages/home_page.dart';
import '../widgets/app_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Só faz login se o formulário estiver válido
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final resp = await http.post(
      Uri.parse('http://192.168.3.19:3000/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': _emailCtrl.text.trim(),
        'senha': _senhaCtrl.text,
      }),
    );
    setState(() => _loading = false);

    if (resp.statusCode == 200) {
      final data = jsonDecode(utf8.decode(resp.bodyBytes));
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: {'id': data['id'], 'nome': data['nome']},
      );
    } else {
      final msg = jsonDecode(resp.body)['detail'] ?? 'Erro ao autenticar';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset('assets/logo.png', height: 200),
                  const SizedBox(height: 32),

                  // E-mail
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'E-mail obrigatório';
                      }
                      final email = v.trim();
                      final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                      if (!regex.hasMatch(email)) {
                        return 'E-mail inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Senha
                  TextFormField(
                    controller: _senhaCtrl,
                    decoration: const InputDecoration(labelText: 'Senha'),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Senha obrigatória';
                      }
                      if (v.length < 6) {
                        return 'A senha deve ter ao menos 6 caracteres';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 24),

                  // Botão Entrar
                  _loading
                      ? const CircularProgressIndicator()
                      : AppButton(
                          label: 'Entrar',
                          icon: Icons.login,
                          onPressed: _login,
                        ),

                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/cadastro'),
                    child: const Text('Criar conta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/app_button.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({Key? key}) : super(key: key);

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _cadastrar() async {
    // só tenta enviar se o form estiver válido
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final resp = await http.post(
      Uri.parse('http://192.168.3.19:3000/api/cadastro'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': _nomeCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'senha': _senhaCtrl.text,
      }),
    );
    setState(() => _loading = false);

    if (resp.statusCode == 200) {
      Navigator.pop(context);
    } else {
      final msg = jsonDecode(resp.body)['detail'] ?? 'Erro ao cadastrar';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
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

                  TextFormField(
                    controller: _nomeCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Nome completo'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Por favor, digite seu nome completo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Por favor, digite seu e-mail';
                      }
                      final email = v.trim();
                      final emailRegex = RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                      if (!emailRegex.hasMatch(email)) {
                        return 'E-mail inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _senhaCtrl,
                    decoration: const InputDecoration(labelText: 'Senha'),
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Por favor, digite uma senha';
                      }
                      if (v.length < 6) {
                        return 'A senha deve ter ao menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _loading
                      ? const CircularProgressIndicator()
                      : AppButton(
                          label: 'Cadastrar',
                          icon: Icons.check,
                          onPressed: _cadastrar,
                        ),

                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Já possui uma conta? Entrar'),
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

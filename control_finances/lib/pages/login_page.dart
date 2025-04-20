import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _loading = false;
  String? _mensagem;

  Future<void> _fazerLogin() async {
    setState(() {
      _loading = true;
      _mensagem = null;
    });

    final uri = Uri.parse('http://10.0.2.2:3000/api/login');
    final body = jsonEncode({
      'email': _emailController.text,
      'senha': _senhaController.text,
      'nome': 'não precisa mas tá no model' // só pra evitar erro de model, ignorado na API
    });

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _mensagem = "Bem-vindo, ${data['nome']}!";
        });

        // Ir para tela principal
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        setState(() {
          _mensagem = "Erro: ${jsonDecode(response.body)['detail']}";
        });
      }
    } catch (e) {
      setState(() {
        _mensagem = "Erro de conexão: $e";
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6F5D6),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Control Finances", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            const Text("Entrar", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Digite seu email"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _senhaController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Digite sua senha"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _fazerLogin,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Acessar"),
            ),
            const SizedBox(height: 20),
            if (_mensagem != null)
              Text(
                _mensagem!,
                style: TextStyle(
                    color: _mensagem!.contains("Bem-vindo") ? Colors.green : Colors.red),
              ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/cadastro');
              },
              child: const Text("Ainda não possui uma conta? Cadastre-se"),
            )
          ],
        ),
      ),
    );
  }
}
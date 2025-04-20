import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _loading = false;
  String? _mensagem;

  Future<void> _cadastrarUsuario() async {
    setState(() {
      _loading = true;
      _mensagem = null;
    });

    final uri = Uri.parse('http://10.0.2.2:3000/api/cadastro');
    final body = jsonEncode({
      'nome': _nomeController.text,
      'email': _emailController.text,
      'senha': _senhaController.text,
    });

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        setState(() {
          _mensagem = "Cadastro realizado com sucesso!";
        });
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Criar Conta", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: "Nome completo"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _senhaController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Senha"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _cadastrarUsuario,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Cadastrar"),
            ),
            const SizedBox(height: 20),
            if (_mensagem != null)
              Text(
                _mensagem!,
                style: TextStyle(color: _mensagem!.contains("sucesso") ? Colors.green : Colors.red),
              ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Já possui uma conta? Entrar"),
            )
          ],
        ),
      ),
    );
  }
}
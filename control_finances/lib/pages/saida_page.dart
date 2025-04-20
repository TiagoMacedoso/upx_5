import 'package:flutter/material.dart';

class SaidaPage extends StatelessWidget {
  const SaidaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nova Saída"), backgroundColor: Colors.green),
      body: const Center(child: Text("Formulário de saída aqui")),
    );
  }
}

import 'package:flutter/material.dart';

class EntradaPage extends StatelessWidget {
  const EntradaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nova Entrada"), backgroundColor: Colors.green),
      body: const Center(child: Text("Formulário de entrada aqui")),
    );
  }
}
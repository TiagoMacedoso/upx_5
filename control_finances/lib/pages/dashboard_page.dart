import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard"), backgroundColor: Colors.green),
      body: const Center(child: Text("Resumo e gráficos aqui")),
    );
  }
}

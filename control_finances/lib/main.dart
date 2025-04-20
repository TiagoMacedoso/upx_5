import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/cadastro_page.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const ControlFinancesApp());
}

class ControlFinancesApp extends StatelessWidget {
  const ControlFinancesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control Finances',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginPage(),
        '/cadastro': (_) => const CadastroPage(),
        '/home': (_) => const HomePage(),
      },
    );
  }
}

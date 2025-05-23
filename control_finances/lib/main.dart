import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:control_finances/pages/login_page.dart';
import 'package:control_finances/pages/cadastro_page.dart';
import 'package:control_finances/pages/home_page.dart';
import 'package:control_finances/pages/entrada_page.dart';
import 'package:control_finances/pages/saida_page.dart';
import 'package:control_finances/pages/dashboard_page.dart';
import 'package:control_finances/pages/chat_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // inicializa dados de formatação para pt_BR
  await initializeDateFormatting('pt_BR', null);
  runApp(const ControlFinancesApp());
}

class ControlFinancesApp extends StatelessWidget {
  const ControlFinancesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control Finances',
      debugShowCheckedModeBanner: false,

      // 1) Localizações
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: Colors.green.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.green,
            textStyle: const TextStyle(fontSize: 14),
          ),
        ),
      ),

      initialRoute: '/login',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case '/cadastro':
            return MaterialPageRoute(builder: (_) => const CadastroPage());
          case '/home':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => HomePage(
                usuarioId: args['id'] as int,
                usuarioNome: args['nome'] as String,
              ),
            );
          case '/entrada':
            final id = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => EntradaPage(usuarioId: id),
            );
          case '/saida':
            final id2 = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => SaidaPage(usuarioId: id2),
            );
          case '/dashboard':
            final id3 = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => DashboardPage(usuarioId: id3),
            );
          case '/chat': // ← nova rota nomeada para o chatbot
            final uid = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => ChatPage(usuarioId: uid),
            );
          default:
            return null;
        }
      },
    );
  }
}
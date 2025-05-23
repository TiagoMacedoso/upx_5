import 'dart:convert';
import 'package:control_finances/pages/login_page.dart';
import 'package:control_finances/pages/dashboard_page.dart';
import 'package:control_finances/pages/registros_page.dart';
import 'package:control_finances/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  final int usuarioId;
  final String usuarioNome;

  const HomePage({
    Key? key,
    required this.usuarioId,
    required this.usuarioNome,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String get _firstName => widget.usuarioNome.split(' ').first;

  final List<String> _instituicoes = [
    'Todas',
    'Caixa Econômica Federal',
    'Bradesco',
    'Nubank',
    'Itaú Unibanco',
    'Banco do Brasil',
    'Santander Brasil',
    'Banco Inter',
    'BTG Pactual',
    'Banco Safra',
    'Banco Original',
  ];
  String _instituicaoSelecionada = 'Todas';

  final List<String> _categorias = [
    'Alimentação',
    'Transporte',
    'Moradia',
    'Saúde',
    'Educação',
    'Lazer',
    'Compras',
    'Assinaturas',
    'Investimentos',
    'Outros',
  ];
  List<String> _categoriasSelecionadas = [];

  bool _loading = false;
  double _saldo = 0, _totalEntradas = 0, _totalSaidas = 0;
  List<Map<String, dynamic>> _entradas = [];
  List<Map<String, dynamic>> _saidas = [];

  static const _headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  @override
  void initState() {
    super.initState();
    _categoriasSelecionadas = List.from(_categorias);
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _loading = true);
    final uri = Uri.parse(
      'http://192.168.3.19:3000/api/dashboard/${widget.usuarioId}',
    ).replace(query: [
      if (_instituicaoSelecionada != 'Todas')
        'instituicao=${Uri.encodeComponent(_instituicaoSelecionada)}',
    ].join('&'));

    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final jsonBody = jsonDecode(utf8.decode(resp.bodyBytes));
      final allEntradas = List<Map<String, dynamic>>.from(
        jsonBody['recent_entradas'],
      );
      final allSaidas = List<Map<String, dynamic>>.from(
        jsonBody['recent_saidas'],
      );
      final filteredSaidas = allSaidas.where(
        (s) => _categoriasSelecionadas.contains(s['categoria']),
      ).toList();

      setState(() {
        _saldo = jsonBody['saldo'];
        _totalEntradas = jsonBody['total_entradas'];
        _totalSaidas = jsonBody['total_saidas'];
        _entradas = allEntradas;
        _saidas = filteredSaidas;
      });
    }
    setState(() => _loading = false);
  }

  String _fmtMoney(double v) =>
      NumberFormat.simpleCurrency(locale: 'pt_BR').format(v);

  String _fmtDate(String iso) =>
      DateFormat('dd/MM/yyyy').format(DateTime.parse(iso));

  Widget _buildCategoryChip(String label) {
    final selected = _categoriasSelecionadas.contains(label);
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (val) {
        setState(() {
          if (val) {
            _categoriasSelecionadas.add(label);
          } else {
            _categoriasSelecionadas.remove(label);
          }
        });
        _loadDashboard();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, $_firstName', style: _headingStyle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Botões 2×2
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.arrow_downward, size: 28),
                          label: const Text('Nova Entrada'),
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/entrada',
                            arguments: widget.usuarioId,
                          ).then((_) => _loadDashboard()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.bar_chart, size: 28),
                          label: const Text('Dashboard'),
                          style:
                              ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DashboardPage(usuarioId: widget.usuarioId),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.arrow_upward, size: 28),
                          label: const Text('Nova Saída'),
                          style:
                              ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/saida',
                            arguments: widget.usuarioId,
                          ).then((_) => _loadDashboard()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.list, size: 28),
                          label: const Text('Registros'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RegistrosPage(usuarioId: widget.usuarioId),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // **Quinto botão: Chat**
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.chat_bubble_outline, size: 28),
                      label: const Text('Chatbot'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ChatPage(usuarioId: widget.usuarioId),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Filtros
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Instituição', style: _headingStyle),
                          DropdownButton<String>(
                            value: _instituicaoSelecionada,
                            items: _instituicoes
                                .map((i) =>
                                    DropdownMenuItem(value: i, child: Text(i)))
                                .toList(),
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => _instituicaoSelecionada = v);
                              _loadDashboard();
                            },
                          ),
                          const SizedBox(height: 8),
                          const Text('Categorias', style: _headingStyle),
                          Wrap(
                            spacing: 6,
                            children:
                                _categorias.map(_buildCategoryChip).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Resumo
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      title: const Text('Saldo Atual', style: _headingStyle),
                      trailing: Text(_fmtMoney(_saldo),
                          style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          color: Colors.green[50],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: const Text('Entradas', style: _headingStyle),
                            trailing: Text(_fmtMoney(_totalEntradas),
                                style: const TextStyle(
                                    color: Colors.green, fontSize: 18)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          color: Colors.red[50],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: const Text('Saídas', style: _headingStyle),
                            trailing: Text(_fmtMoney(_totalSaidas),
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 18)),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  // Últimas Entradas
                  const Text('Últimas Entradas', style: _headingStyle),
                  ..._entradas.map((e) => Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const Icon(Icons.arrow_downward,
                              color: Colors.green),
                          title: Text(e['descricao'] ?? '—'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_fmtDate(e['data'])),
                              Text('Instituição: ${e['instituicao']}'),
                            ],
                          ),
                          trailing: Text(_fmtMoney(e['valor'])),
                        ),
                      )),
                  const SizedBox(height: 16),
                  // Últimas Saídas
                  const Text('Últimas Saídas', style: _headingStyle),
                  ..._saidas.map((s) => Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const Icon(Icons.arrow_upward,
                              color: Colors.red),
                          title: Text(s['descricao'] ?? '—'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_fmtDate(s['data'])),
                              Text('Categoria: ${s['categoria']}'),
                              Text('Instituição: ${s['instituicao']}'),
                            ],
                          ),
                          trailing: Text(_fmtMoney(s['valor'])),
                        ),
                      )),
                ],
              ),
            ),
    );
  }
}

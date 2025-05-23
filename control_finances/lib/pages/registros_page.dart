import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:control_finances/pages/login_page.dart';
import 'package:control_finances/pages/entrada_page.dart';
import 'package:control_finances/pages/saida_page.dart';

class RegistrosPage extends StatefulWidget {
  final int usuarioId;
  const RegistrosPage({Key? key, required this.usuarioId}) : super(key: key);

  @override
  State<RegistrosPage> createState() => _RegistrosPageState();
}

class _RegistrosPageState extends State<RegistrosPage> {
  static const _headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  bool _loading = true;
  List<Map<String, dynamic>> _entradas = [];
  List<Map<String, dynamic>> _saidas = [];

  // filtro de instituições
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

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() => _loading = true);
    final eResp = await http.get(
      Uri.parse('http://192.168.3.19:3000/api/entradas/${widget.usuarioId}'),
    );
    final sResp = await http.get(
      Uri.parse('http://192.168.3.19:3000/api/saidas/${widget.usuarioId}'),
    );
    if (eResp.statusCode == 200 && sResp.statusCode == 200) {
      _entradas = List<Map<String, dynamic>>.from(
        jsonDecode(utf8.decode(eResp.bodyBytes)),
      );
      _saidas = List<Map<String, dynamic>>.from(
        jsonDecode(utf8.decode(sResp.bodyBytes)),
      );
    }
    setState(() => _loading = false);
  }

  Future<void> _deleteRecord(String tipo, int id) async {
    final resp = await http.delete(
      Uri.parse('http://192.168.3.19:3000/api/$tipo/$id'),
    );
    if (resp.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$tipo $id excluído com sucesso')),
      );
      _fetchAll();
    }
  }

  String _fmtDate(String iso) =>
      DateFormat('dd/MM/yyyy').format(DateTime.parse(iso));
  String _fmtMoney(double v) =>
      NumberFormat.simpleCurrency(locale: 'pt_BR').format(v);

  Widget _buildEntryCard(Map<String, dynamic> e) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Conteúdo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.arrow_downward, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e['descricao'] ?? '—',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Data: ${_fmtDate(e['data'])}'),
                  Text('Instituição: ${e['instituicao']}'),
                  const SizedBox(height: 8),
                  Text(
                    _fmtMoney((e['valor'] as num).toDouble()),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // Botões
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EntradaPage(
                          usuarioId: widget.usuarioId,
                          entradaId: e['id'],
                        ),
                      ),
                    );
                    _fetchAll();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteRecord('entrada', e['id']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExitCard(Map<String, dynamic> s) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Conteúdo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.arrow_upward, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          s['descricao'] ?? '—',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Data: ${_fmtDate(s['data'])}'),
                  Text('Categoria: ${s['categoria']}'),
                  if (s['subcategoria'] != null)
                    Text('Subcategoria: ${s['subcategoria']}'),
                  Text('Instituição: ${s['instituicao']}'),
                  const SizedBox(height: 8),
                  Text(
                    _fmtMoney((s['valor'] as num).toDouble()),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // Botões
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SaidaPage(
                          usuarioId: widget.usuarioId,
                          saidaId: s['id'],
                        ),
                      ),
                    );
                    _fetchAll();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteRecord('saida', s['id']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Aplica filtro localmente
    final displayedEntradas = _instituicaoSelecionada == 'Todas'
        ? _entradas
        : _entradas
            .where((e) => e['instituicao'] == _instituicaoSelecionada)
            .toList();
    final displayedSaidas = _instituicaoSelecionada == 'Todas'
        ? _saidas
        : _saidas
            .where((s) => s['instituicao'] == _instituicaoSelecionada)
            .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Registros', style: _headingStyle),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: const TabBar(
            tabs: [Tab(text: 'Entradas'), Tab(text: 'Saídas')],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Dropdown de Instituição
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Instituição'),
                      items: _instituicoes
                          .map((i) =>
                              DropdownMenuItem(value: i, child: Text(i)))
                          .toList(),
                      value: _instituicaoSelecionada,
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _instituicaoSelecionada = v);
                      },
                    ),
                  ),

                  // Conteúdo das tabs
                  Expanded(
                    child: TabBarView(
                      children: [
                        RefreshIndicator(
                          onRefresh: _fetchAll,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: displayedEntradas.length,
                            itemBuilder: (ctx, i) =>
                                _buildEntryCard(displayedEntradas[i]),
                          ),
                        ),
                        RefreshIndicator(
                          onRefresh: _fetchAll,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: displayedSaidas.length,
                            itemBuilder: (ctx, i) =>
                                _buildExitCard(displayedSaidas[i]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

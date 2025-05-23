// lib/pages/dashboard_page.dart

import 'dart:convert';
import 'dart:math'; // for max()
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../widgets/pie_chart_painter.dart';
import '../widgets/bar_chart_painter.dart';

class DashboardPage extends StatefulWidget {
  final int usuarioId;
  const DashboardPage({Key? key, required this.usuarioId}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  DateTime? _fromDate;
  DateTime? _toDate;
  String _instituicao = 'Todas';
  bool _loading = false;

  late TabController _tabController;
  double _saldo = 0.0;

  List<PieChartSection> _pieData = [];
  List<BarChartEntry> _entradaInst = [];
  List<BarChartEntry> _saidaInst = [];

  final _instituicoes = [
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

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
    _tabController = TabController(length: 2, vsync: this);
    _fetchReport();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _fmtMoney(double v) =>
      NumberFormat.simpleCurrency(locale: 'pt_BR').format(v);

  Future<void> _pickDate(bool isFrom) async {
    final initial = isFrom
        ? (_fromDate ?? DateTime.now())
        : (_toDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) _fromDate = picked;
        else _toDate = picked;
      });
      _fetchReport();
    }
  }

  void _clearFromDate() {
    setState(() => _fromDate = null);
    _fetchReport();
  }

  void _clearToDate() {
    setState(() => _toDate = null);
    _fetchReport();
  }

  /// Nova função: limpar ambas as datas de uma só vez
  void _clearAllDates() {
    setState(() {
      _fromDate = null;
      _toDate = null;
    });
    _fetchReport();
  }

  Future<void> _onInstChanged(String? nova) async {
    if (nova == null) return;
    setState(() => _instituicao = nova);
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    setState(() => _loading = true);

    // 1) Relatório de categorias + barras
    final relBase =
        'http://192.168.3.19:3000/api/relatorio/${widget.usuarioId}';
    final relParams = <String, String>{};
    if (_instituicao != 'Todas') relParams['instituicao'] = _instituicao;
    if (_fromDate != null) relParams['date_from'] = _fromDate!.toIso8601String();
    if (_toDate != null) relParams['date_to'] = _toDate!.toIso8601String();
    final relUri = Uri.parse(relBase).replace(queryParameters: relParams);
    final relResp = await http.get(relUri);
    if (relResp.statusCode == 200) {
      final j = jsonDecode(relResp.body);
      _pieData = (j['por_categoria'] as List).map((obj) {
        return PieChartSection(
          (obj['total'] as num).toDouble(),
          _colorForCategory(obj['categoria'] as String),
          obj['categoria'] as String,
        );
      }).toList();
      _entradaInst = (j['entrada_por_instituicao'] as List).map((e) {
        return BarChartEntry(
          e['instituicao'] as String,
          (e['total'] as num).toDouble(),
          Colors.green,
        );
      }).toList();
      _saidaInst = (j['saida_por_instituicao'] as List).map((e) {
        return BarChartEntry(
          e['instituicao'] as String,
          (e['total'] as num).toDouble(),
          Colors.red,
        );
      }).toList();
    }

    // 2) Saldo filtrado (instituição + datas)
    final dashBase =
        'http://192.168.3.19:3000/api/dashboard/${widget.usuarioId}';
    final dashParams = <String, String>{};
    if (_instituicao != 'Todas') dashParams['instituicao'] = _instituicao;
    if (_fromDate != null) dashParams['date_from'] = _fromDate!.toIso8601String();
    if (_toDate != null) dashParams['date_to'] = _toDate!.toIso8601String();
    final dashUri = Uri.parse(dashBase).replace(queryParameters: dashParams);
    final dashResp = await http.get(dashUri);
    if (dashResp.statusCode == 200) {
      final dj = jsonDecode(dashResp.body);
      _saldo = (dj['saldo'] as num).toDouble();
    }

    setState(() => _loading = false);
  }

  Color _colorForCategory(String cat) {
    const map = {
      'Alimentação': Colors.green,
      'Transporte': Colors.blue,
      'Moradia': Colors.brown,
      'Saúde': Colors.red,
      'Educação': Colors.purple,
      'Lazer': Colors.orange,
      'Compras': Colors.teal,
      'Assinaturas': Colors.indigo,
      'Investimentos': Colors.amber,
      'Outros': Colors.grey,
    };
    return map[cat] ?? Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final slotWidth = screenWidth / 4.5;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          'Dashboard',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── LINHA ÚNICA: Instituição | Saldo | Datas ─────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Instituição
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Instituição'),
                      value: _instituicao,
                      items: _instituicoes
                          .map((i) =>
                              DropdownMenuItem(value: i, child: Text(i)))
                          .toList(),
                      onChanged: _onInstChanged,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Saldo
                  Text(
                    'Saldo: ${_fmtMoney(_saldo)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(width: 24),

                  // Data Início
                  OutlinedButton(
                    onPressed: () => _pickDate(true),
                    child: Text(
                      _fromDate == null
                          ? 'Início'
                          : DateFormat('dd/MM/yyyy').format(_fromDate!),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Data Fim
                  OutlinedButton(
                    onPressed: () => _pickDate(false),
                    child: Text(
                      _toDate == null
                          ? 'Fim'
                          : DateFormat('dd/MM/yyyy').format(_toDate!),
                    ),
                  ),
                  if (_fromDate != null || _toDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.red, size: 20),
                      tooltip: 'Limpar datas',
                      onPressed: _clearAllDates,
                    ),
                ],
              ),
            ),

            // ── CONTEÚDO PRINCIPAL ─────────────────
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Pizza
                          const SizedBox(height: 16),
                          const Text(
                            'Gastos por Categoria',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 300,
                            child: CustomPaint(
                              painter: PieChartPainter(_pieData),
                            ),
                          ),
                          // Legenda
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: _pieData.map((sec) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      color: sec.color,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(sec.label,
                                        style: const TextStyle(fontSize: 14)),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),

                          // Divider
                          const SizedBox(height: 24),
                          Divider(color: Colors.grey.shade300),
                          const SizedBox(height: 24),

                          // Barras
                          const Text(
                            'Entradas e Saídas por Instituição',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),

                          TabBar(
                            controller: _tabController,
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Colors.green,
                            tabs: const [
                              Tab(text: 'Entradas'),
                              Tab(text: 'Saídas'),
                            ],
                          ),

                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    height: double.infinity,
                                    width: max(
                                      screenWidth,
                                      slotWidth * _entradaInst.length,
                                    ),
                                    child: CustomPaint(
                                      painter: BarChartPainter(_entradaInst),
                                    ),
                                  ),
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    height: double.infinity,
                                    width: max(
                                      screenWidth,
                                      slotWidth * _saidaInst.length,
                                    ),
                                    child: CustomPaint(
                                      painter: BarChartPainter(_saidaInst),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

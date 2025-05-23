import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../widgets/app_button.dart';

class EntradaPage extends StatefulWidget {
  final int usuarioId;
  final int? entradaId; // se nulo, estamos criando; senão, editando

  const EntradaPage({
    Key? key,
    required this.usuarioId,
    this.entradaId,
  }) : super(key: key);

  @override
  State<EntradaPage> createState() => _EntradaPageState();
}

class _EntradaPageState extends State<EntradaPage> {
  final _formKey = GlobalKey<FormState>();
  final _valorCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String? _instituicaoSelecionada;
  final List<String> _instituicoes = [
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

  DateTime? _data;
  bool _loading = false;

  bool get _isEdit => widget.entradaId != null;

  static const _headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  @override
  void initState() {
    super.initState();
    if (_isEdit) _loadEntrada();
  }

  Future<void> _loadEntrada() async {
    setState(() => _loading = true);
    final resp = await http.get(
      Uri.parse('http://192.168.3.19:3000/api/entrada/${widget.entradaId}'),
    );
    if (resp.statusCode == 200) {
      final j = jsonDecode(utf8.decode(resp.bodyBytes));
      _descCtrl.text = j['descricao'] ?? '';
      _valorCtrl.text = (j['valor'] as num).toString();
      _instituicaoSelecionada = j['instituicao'];
      _data = DateTime.parse(j['data']);
    }
    setState(() => _loading = false);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate() || _data == null) {
      if (_data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data é obrigatória')),
        );
      }
      return;
    }
    setState(() => _loading = true);

    final body = {
      'usuario_id': widget.usuarioId,
      'descricao': _descCtrl.text,
      'data': _data!.toIso8601String(),
      'instituicao': _instituicaoSelecionada!,
      'valor': double.parse(_valorCtrl.text),
    };

    late final http.Response resp;
    if (_isEdit) {
      resp = await http.put(
        Uri.parse('http://192.168.3.19:3000/api/entrada/${widget.entradaId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } else {
      resp = await http.post(
        Uri.parse('http://192.168.3.19:3000/api/entrada'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    }

    setState(() => _loading = false);
    if (resp.statusCode == 200) {
      Navigator.pop(context);
    } else {
      final msg = jsonDecode(resp.body)['detail'] ?? 'Erro ao salvar';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  String _fmtDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Editar Entrada' : 'Nova Entrada',
          style: _headingStyle,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _descCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Descrição'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Descrição obrigatória' : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Instituição'),
                      items: _instituicoes
                          .map((i) =>
                              DropdownMenuItem(value: i, child: Text(i)))
                          .toList(),
                      value: _instituicaoSelecionada,
                      onChanged: (v) =>
                          setState(() => _instituicaoSelecionada = v),
                      validator: (v) =>
                          v == null ? 'Instituição obrigatória' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _valorCtrl,
                      decoration: const InputDecoration(labelText: 'Valor'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Valor obrigatório';
                        final n = double.tryParse(v.replaceAll(',', '.'));
                        return n == null ? 'Valor inválido' : null;
                      },
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_data == null
                          ? 'Escolha a data'
                          : 'Data: ${_fmtDate(_data!)}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final dt = await showDatePicker(
                          context: context,
                          initialDate: _data ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (dt != null) setState(() => _data = dt);
                      },
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: _isEdit
                          ? 'Atualizar Entrada'
                          : 'Registrar Entrada',
                      icon: Icons.arrow_downward,
                      onPressed: _salvar,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

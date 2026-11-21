import 'dart:io';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/registro.dart';

class DetalhesRegistroScreen extends StatefulWidget {
  final Registro registro;

  const DetalhesRegistroScreen({super.key, required this.registro});

  @override
  State<DetalhesRegistroScreen> createState() => _DetalhesRegistroScreenState();
}

class _DetalhesRegistroScreenState extends State<DetalhesRegistroScreen> {
  late Registro _registro;
  bool _houveAlteracao = false;

  @override
  void initState() {
    super.initState();
    _registro = widget.registro;
  }

  Future<void> _alternarFavorito() async {
    await DatabaseHelper.instance.alternarFavorito(_registro);
    setState(() {
      _registro = _registro.copyWith(favorito: !_registro.favorito);
      _houveAlteracao = true;
    });
  }

  Future<void> _confirmarExclusao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir registro?'),
        content: const Text('Esta ação removerá o registro do banco de dados e apagará a fotografia do aparelho.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await DatabaseHelper.instance.excluirRegistro(_registro);
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _houveAlteracao);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
            onPressed: () => Navigator.pop(context, _houveAlteracao),
          ),
          title: const Text(
            'Detalhes do Registro',
            style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _registro.favorito ? Icons.favorite : Icons.favorite_border,
                color: const Color(0xFF00897B),
              ),
              onPressed: _alternarFavorito,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: _confirmarExclusao,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  File(_registro.caminhoImagem),
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _registro.titulo,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              if (_registro.descricao.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _registro.descricao,
                  style: const TextStyle(fontSize: 16, color: Color(0xFF475569), height: 1.4),
                ),
              ],
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _infoTile(Icons.calendar_today, 'Data e Hora', _registro.dataHora),
                    const Divider(height: 24),
                    _infoTile(Icons.place, 'Localidade', _registro.localidade),
                    const Divider(height: 24),
                    _infoTile(
                      Icons.my_location,
                      'Coordenadas GPS',
                      'Lat: ${_registro.latitude.toStringAsFixed(6)} | Long: ${_registro.longitude.toStringAsFixed(6)}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String titulo, String valor) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFFE0F2F1),
          child: Icon(icon, color: const Color(0xFF00897B), size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
              Text(
                valor,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

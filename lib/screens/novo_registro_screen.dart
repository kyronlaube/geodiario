import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../database/database_helper.dart';
import '../models/registro.dart';
import '../services/location_service.dart';

class NovoRegistroScreen extends StatefulWidget {
  const NovoRegistroScreen({super.key});

  @override
  State<NovoRegistroScreen> createState() => _NovoRegistroScreenState();
}

class _NovoRegistroScreenState extends State<NovoRegistroScreen> {
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _imagemSelecionada;
  String _dataHoraFormatada = '';
  double? _latitude;
  double? _longitude;
  String _localidade = 'Obtendo localização...';
  bool _carregandoGps = false;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _atualizarDataHora();
    _capturarLocalizacao();
  }

  void _atualizarDataHora() {
    final agora = DateTime.now();
    _dataHoraFormatada = DateFormat('dd/MM/yyyy • HH:mm').format(agora);
  }

  Future<void> _capturarLocalizacao() async {
    setState(() => _carregandoGps = true);
    try {
      final dados = await LocationService.obterLocalizacaoAtual();
      if (!mounted) return;
      setState(() {
        _latitude = dados.latitude;
        _longitude = dados.longitude;
        _localidade = dados.localidade;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _localidade = 'GPS indisponível';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _carregandoGps = false);
    }
  }

  Future<void> _capturarFoto(ImageSource origem) async {
    final XFile? foto = await _picker.pickImage(
      source: origem,
      imageQuality: 85,
    );

    if (foto != null) {
      _atualizarDataHora();
      setState(() {
        _imagemSelecionada = File(foto.path);
      });
      if (_latitude == null) {
        _capturarLocalizacao();
      }
    }
  }

  Future<void> _salvarRegistro() async {
    if (_imagemSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, capture uma fotografia antes de salvar.')),
      );
      return;
    }

    if (_tituloController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um título para o registro.')),
      );
      return;
    }

    setState(() => _salvando = true);

    try {
      final diretorioApp = await getApplicationDocumentsDirectory();
      final nomeArquivo = 'geo_${DateTime.now().millisecondsSinceEpoch}${p.extension(_imagemSelecionada!.path)}';
      final caminhoPermanente = p.join(diretorioApp.path, nomeArquivo);
      await _imagemSelecionada!.copy(caminhoPermanente);

      final novoRegistro = Registro(
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        caminhoImagem: caminhoPermanente,
        dataHora: _dataHoraFormatada,
        latitude: _latitude ?? 0.0,
        longitude: _longitude ?? 0.0,
        localidade: _localidade,
      );

      await DatabaseHelper.instance.inserirRegistro(novoRegistro);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar registro: $e')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Icon(Icons.location_on, color: Color(0xFF00897B), size: 28),
            const SizedBox(width: 4),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(text: 'Geo', style: TextStyle(color: Color(0xFF1E293B))),
                  TextSpan(text: 'Diário', style: TextStyle(color: Color(0xFF00897B))),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Novo registro',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _capturarFoto(ImageSource.camera),
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: _imagemSelecionada != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(17),
                        child: Image.file(_imagemSelecionada!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.camera_alt_rounded, size: 48, color: Color(0xFF00897B)),
                          const SizedBox(height: 8),
                          const Text(
                            'Toque para abrir a câmera',
                            style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                          ),
                          TextButton.icon(
                            onPressed: () => _capturarFoto(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library_outlined, size: 18),
                            label: const Text('Ou escolher da galeria'),
                          ),
                        ],
                      ),
              ),
            ),
            if (_imagemSelecionada != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _capturarFoto(ImageSource.camera),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Tirar outra foto'),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _tituloController,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Título do local ou acontecimento',
                hintText: 'Ex: Praça da Liberdade',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descricaoController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Descrição (opcional)',
                hintText: 'Observações sobre o registro...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildMetaRow('Data e hora', _dataHoraFormatada),
                  const Divider(height: 20),
                  _buildMetaRow(
                    'Localização',
                    _carregandoGps ? 'Buscando sinal GPS...' : _localidade,
                  ),
                  const SizedBox(height: 8),
                  _buildMetaRow(
                    'Coordenadas',
                    _latitude != null && _longitude != null
                        ? 'Lat ${_latitude!.toStringAsFixed(4)}   Long ${_longitude!.toStringAsFixed(4)}'
                        : 'Aguardando GPS...',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _salvando ? null : _salvarRegistro,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _salvando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Salvar registro',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            valor,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/registro.dart';
import 'novo_registro_screen.dart';
import 'detalhes_registro_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _abaAtual = 0;
  int _filtroChip = 0;
  bool _exibirBusca = false;
  String _termoBusca = '';
  List<Registro> _registros = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarRegistros();
  }

  Future<void> _carregarRegistros() async {
    setState(() => _carregando = true);
    final dados = await DatabaseHelper.instance.listarRegistros(
      busca: _termoBusca,
      apenasFavoritos: _filtroChip == 1,
    );
    setState(() {
      _registros = dados;
      _carregando = false;
    });
  }

  Future<void> _abrirNovoRegistro() async {
    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const NovoRegistroScreen()),
    );
    if (salvou == true) {
      _carregarRegistros();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (_exibirBusca) _buildSearchBar(),
            if (_abaAtual == 0) _buildFilterChips(),
            Expanded(
              child: _abaAtual == 3
                  ? _buildPerfilView()
                  : (_abaAtual == 1 || _filtroChip == 2)
                      ? _buildResumoMapaView()
                      : _buildListaRegistros(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF00897B), size: 34),
              const SizedBox(width: 6),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                  children: [
                    TextSpan(text: 'Geo', style: TextStyle(color: Color(0xFF1E293B))),
                    TextSpan(text: 'Diário', style: TextStyle(color: Color(0xFF00897B))),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(_exibirBusca ? Icons.close : Icons.search, color: const Color(0xFF1E293B), size: 26),
                onPressed: () {
                  setState(() {
                    _exibirBusca = !_exibirBusca;
                    if (!_exibirBusca) {
                      _termoBusca = '';
                      _carregarRegistros();
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF1E293B), size: 26),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${_registros.length} registros salvos localmente no SQLite.')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Buscar por título ou local...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF00897B)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (valor) {
          _termoBusca = valor;
          _carregarRegistros();
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Meus Registros • 2026',
            style: TextStyle(fontSize: 15, color: Color(0xFF475569), fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildChip('Todos ${_registros.length}', 0),
              const SizedBox(width: 10),
              _buildChip('Favoritos', 1),
              const SizedBox(width: 10),
              _buildChip('Mapa', 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, int index) {
    final ativo = _filtroChip == index;
    return GestureDetector(
      onTap: () {
        setState(() => _filtroChip = index);
        if (index != 2) _carregarRegistros();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: ativo ? const Color(0xFF00897B) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: ativo ? Colors.white : const Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildListaRegistros() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00897B)));
    }

    if (_registros.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'Nenhum registro encontrado',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Toque em "+ Novo" na barra inferior para fotografar um local com GPS.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      itemCount: _registros.length,
      itemBuilder: (context, index) {
        final item = _registros[index];
        return _buildRegistroCard(item);
      },
    );
  }

  Widget _buildRegistroCard(Registro item) {
    return GestureDetector(
      onTap: () async {
        final alterou = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => DetalhesRegistroScreen(registro: item)),
        );
        if (alterou == true) _carregarRegistros();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(item.caminhoImagem),
                width: 92,
                height: 92,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 92,
                  height: 92,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.titulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      if (item.favorito)
                        const Icon(Icons.favorite, color: Color(0xFF00897B), size: 18),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        item.dataHora,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.access_time, size: 14, color: Color(0xFF64748B)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 15, color: Color(0xFF00897B)),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          'GPS: ${item.latitude.toStringAsFixed(4)}, ${item.longitude.toStringAsFixed(4)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${item.localidade.split('•').last.trim()} — Registro concluído',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF00695C),
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildResumoMapaView() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.map_outlined, color: Color(0xFF00897B)),
                  SizedBox(width: 8),
                  Text(
                    'Coordenadas Registradas',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_registros.isEmpty)
                const Text('Nenhuma coordenada salva ainda.')
              else
                ..._registros.map(
                  (r) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE0F2F1),
                      child: Icon(Icons.pin_drop, color: Color(0xFF00897B)),
                    ),
                    title: Text(r.titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      '${r.localidade}\nLat ${r.latitude.toStringAsFixed(4)} • Long ${r.longitude.toStringAsFixed(4)}',
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DetalhesRegistroScreen(registro: r)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerfilView() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 36,
              backgroundColor: Color(0xFFE0F2F1),
              child: Icon(Icons.person, size: 40, color: Color(0xFF00897B)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Diário Fotográfico Local',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Total de memórias salvas: ${_registros.length}',
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            const Divider(height: 28),
            const ListTile(
              leading: Icon(Icons.storage, color: Color(0xFF00897B)),
              title: Text('Banco de Dados'),
              subtitle: Text('SQLite local (sqflite) ativo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _abaAtual,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF00897B),
        unselectedItemColor: const Color(0xFF64748B),
        onTap: (index) {
          if (index == 2) {
            _abrirNovoRegistro();
          } else {
            setState(() {
              _abaAtual = index;
              if (index == 0) _filtroChip = 0;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.article_outlined), label: 'Registros'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline, size: 28), label: 'Novo'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}

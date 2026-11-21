class Registro {
  final int? id;
  final String titulo;
  final String descricao;
  final String caminhoImagem;
  final String dataHora;
  final double latitude;
  final double longitude;
  final String localidade;
  final bool favorito;

  Registro({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.caminhoImagem,
    required this.dataHora,
    required this.latitude,
    required this.longitude,
    required this.localidade,
    this.favorito = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'caminho_imagem': caminhoImagem,
      'data_hora': dataHora,
      'latitude': latitude,
      'longitude': longitude,
      'localidade': localidade,
      'favorito': favorito ? 1 : 0,
    };
  }

  factory Registro.fromMap(Map<String, dynamic> map) {
    return Registro(
      id: map['id'],
      titulo: map['titulo'],
      descricao: map['descricao'] ?? '',
      caminhoImagem: map['caminho_imagem'],
      dataHora: map['data_hora'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      localidade: map['localidade'] ?? 'Localização registrada',
      favorito: (map['favorito'] ?? 0) == 1,
    );
  }

  Registro copyWith({bool? favorito}) {
    return Registro(
      id: id,
      titulo: titulo,
      descricao: descricao,
      caminhoImagem: caminhoImagem,
      dataHora: dataHora,
      latitude: latitude,
      longitude: longitude,
      localidade: localidade,
      favorito: favorito ?? this.favorito,
    );
  }
}

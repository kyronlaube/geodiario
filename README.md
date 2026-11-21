**GeoDiário**



Aplicativo móvel desenvolvido em **Flutter** e **Dart** para o registro de fotografias associadas automaticamente à data, horário e coordenadas geográficas (GPS), com armazenamento local em SQLite.

Funcionalidades Implementadas

* **RF01 – Captura de Fotografia:** Captura de fotos via câmera do dispositivo (com opção de seleção da galeria).
* **RF02 – Metadados Automáticos:** Associação automática de data/hora atual, latitude, longitude e geocodificação reversa (cidade/bairro), além de título e descrição informados pelo usuário.
* **RF03 – Armazenamento Local:** Persistência dos dados textuais e caminho da imagem utilizando banco de dados SQLite (`sqflite`) e cópia segura da imagem no diretório interno do app.
* **RF04 – Consulta e Filtros:** Listagem dos registros em cards com busca por texto e filtro por favoritos.
* **RF05 – Visualização e Exclusão:** Tela detalhada da fotografia e metadados, com opção de favoritar e excluir o registro (apagando tanto o registro no SQLite quanto o arquivo físico da imagem).



**Bibliotecas Utilizadas**



* `sqflite`: Persistência de dados relacional local em SQLite.
* `path` e `path\\\_provider`: Gerenciamento de caminhos e armazenamento local dos arquivos de imagem.
* `image\\\_picker`: Acesso à câmera nativa e à galeria de imagens.
* `geolocator`: Obtenção das coordenadas geográficas (latitude e longitude) via GPS.
* `geocoding`: Conversão de coordenadas em endereço legível (cidade/bairro).
* `intl`: Formatação de data e hora.



**Estrutura da Tabela SQLite (`registros`)**



|Coluna|Tipo|Descrição|
|-|-|-|
|`id`|`INTEGER PRIMARY KEY AUTOINCREMENT`|Identificador único do registro|
|`titulo`|`TEXT NOT NULL`|Título do local ou evento|
|`descricao`|`TEXT`|Observações adicionais do usuário|
|`caminho\\\_imagem`|`TEXT NOT NULL`|Caminho absoluto da foto salva localmente|
|`data\\\_hora`|`TEXT NOT NULL`|Data e hora da captura|
|`latitude`|`REAL NOT NULL`|Latitude obtida pelo GPS|
|`longitude`|`REAL NOT NULL`|Longitude obtida pelo GPS|
|`localidade`|`TEXT`|Cidade/bairro obtidos via geocodificação|
|`favorito`|`INTEGER DEFAULT 0`|Indicador de favorito (`0` ou `1`)|



**Como Executar**



1. Crie um projeto Flutter base (`flutter create geodiario`) ou utilize os arquivos deste repositório.
2. Copie a pasta `lib/`, `pubspec.yaml` e as permissões de `android/` e `ios/`.
3. Execute `flutter pub get` e `flutter run`.


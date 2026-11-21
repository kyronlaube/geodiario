import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class DadosLocalizacao {
  final double latitude;
  final double longitude;
  final String localidade;

  DadosLocalizacao({
    required this.latitude,
    required this.longitude,
    required this.localidade,
  });
}

class LocationService {
  static Future<DadosLocalizacao> obterLocalizacaoAtual() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('O serviço de GPS está desativado no dispositivo.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permissão de localização bloqueada nas configurações.');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    String localidadeFormatada = 'Localização GPS';
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final bairro = place.subLocality ?? '';
        final cidade = place.subAdministrativeArea ?? place.locality ?? '';
        final estado = place.administrativeArea ?? '';
        localidadeFormatada = [cidade, estado, bairro]
            .where((part) => part.isNotEmpty)
            .join(' • ');
      }
    } catch (_) {}

    return DadosLocalizacao(
      latitude: position.latitude,
      longitude: position.longitude,
      localidade: localidadeFormatada,
    );
  }
}

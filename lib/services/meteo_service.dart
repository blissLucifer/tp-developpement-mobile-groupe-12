import 'package:dio/dio.dart';
import '../models/meteo_data.dart';
import '../models/prevision_jour.dart';

class MeteoService {
  static const Map<String, List<double>> _coords = {
    'Cotonou':     [6.3703,    2.3912],
    'Parakou':     [9.3370,    2.6283],
    'Lagos':       [6.4541,    3.3947],
    'Abidjan':     [5.3600,   -4.0083],
    'Dakar':       [14.6937, -17.4441],
    'Avrankou':    [6.5574,    2.6554],
    'Lome':        [6.1375,    1.2123],
    'Accra':       [5.5600,   -0.2057],
    'Bamako':      [12.6392,  -8.0029],
    'Niamey':      [13.5137,   2.1098],
    'Ouagadougou': [12.3647,  -1.5332],
    'Douala':      [4.0511,    9.7679],
    'Kinshasa':    [-4.3217,  15.3222],
    'Abuja':       [9.0765,    7.3986],
    'Natitingou':  [10.3167,   1.3833],
    'Dassa':       [7.7833, 2.1833],
  };

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.open-meteo.com/v1',
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));

  MeteoService() {
    _dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      logPrint: (msg) => print('[DIO] $msg'),
    ));
  }

  Future<MeteoData?> getMeteo(String nomVille) async {
    final coords = _coords[nomVille];
    if (coords == null) {
      print('Ville inconnue : $nomVille');
      return null;
    }

    try {
      final response = await _dio.get('/forecast', queryParameters: {
        'latitude':  coords[0],
        'longitude': coords[1],
        'current':   'temperature_2m,relative_humidity_2m,weathercode',
        'daily':     'temperature_2m_max,temperature_2m_min,weathercode',
        'timezone':  'Africa/Lagos',
        'forecast_days': 3,
      });

      final current = response.data['current'] as Map<String, dynamic>;
      return MeteoData.fromJson(current);

    } on DioException catch (e) {
      print('Erreur réseau : ${e.message}');
      return null;
    }
  }

  Future<List<PrevisionJour>> getPrevisions(String nomVille) async {
    final coords = _coords[nomVille];
    if (coords == null) return [];

    try {
      final response = await _dio.get('/forecast', queryParameters: {
        'latitude':      coords[0],
        'longitude':     coords[1],
        'daily':         'temperature_2m_max,temperature_2m_min,weathercode',
        'timezone':      'Africa/Lagos',
        'forecast_days': 3,
      });

      final daily  = response.data['daily'] as Map<String, dynamic>;
      final dates  = daily['time'] as List;
      final maxs   = daily['temperature_2m_max'] as List;
      final mins   = daily['temperature_2m_min'] as List;
      final codes  = daily['weathercode'] as List;

      return List.generate(3, (i) => PrevisionJour(
        date:        dates[i] as String,
        tempMax:     (maxs[i] as num).toDouble(),
        tempMin:     (mins[i] as num).toDouble(),
        weatherCode: (codes[i] as num).toInt(),
      ));

    } on DioException catch (e) {
      print('Erreur prévisions : ${e.message}');
      return [];
    }
  }
}
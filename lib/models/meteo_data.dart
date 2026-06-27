class MeteoData {
  final double temperature;  // Température en Celsius
  final int humidite;  // Humidité en %
  final int weatherCode; // Code WMO (0 = ensoleillé, 61 = pluvieux, ...)
  final String time;

  MeteoData({
    required this.temperature,
    required this.humidite,
    required this.weatherCode,
    required this.time,
  });

  factory MeteoData.fromJson(Map<String, dynamic> json) {
    return MeteoData(
      temperature: (json['temperature_2m'] as num).toDouble(),
      humidite:    (json['relative_humidity_2m'] as num).toInt(),
      weatherCode: (json['weathercode'] as num).toInt(),
      time:        json['time'] as String,
    );
  }

  String get conditionTexte {
    if (weatherCode == 0) return 'Ensoleillé';
    if (weatherCode <= 3) return 'Nuageux';
    if (weatherCode >= 51 && weatherCode <= 67) return 'Pluvieux';
    if (weatherCode >= 80 && weatherCode <= 82) return 'Averses';
    if (weatherCode >= 95) return 'Orageux';
    return 'Variable';
  }

  // Retourne true si T > 40°C ou orage (weatherCode >= 95)
  bool estDangereux() {
    return temperature > 40 || weatherCode >= 95;
  }

  String get dateMesure {
    final dt    = DateTime.parse(time);
    final jour  = dt.day.toString().padLeft(2, '0');
    final mois  = dt.month.toString().padLeft(2, '0');
    final annee = dt.year;
    final heure = dt.hour.toString().padLeft(2, '0');
    final min   = dt.minute.toString().padLeft(2, '0');
    return 'Mesure du $jour/$mois/$annee à ${heure}h$min';
  }
}
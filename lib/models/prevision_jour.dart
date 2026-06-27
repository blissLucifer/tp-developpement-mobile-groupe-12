class PrevisionJour {
  final String date;
  final double tempMax;
  final double tempMin;
  final int weatherCode;

  PrevisionJour({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.weatherCode,
  });

  String get conditionTexte {
    if (weatherCode == 0) return 'Ensoleillé';
    if (weatherCode <= 3) return 'Nuageux';
    if (weatherCode >= 51 && weatherCode <= 67) return 'Pluvieux';
    if (weatherCode >= 80 && weatherCode <= 82) return 'Averses';
    if (weatherCode >= 95) return 'Orageux';
    return 'Variable';
  }

  String get jourFormate {
    final dt = DateTime.parse(date);
    final jour = dt.day.toString().padLeft(2, '0');
    final mois = dt.month.toString().padLeft(2, '0');
    return '$jour/$mois';
  }
}

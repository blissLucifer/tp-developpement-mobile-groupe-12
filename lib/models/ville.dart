class Ville {
  final String nom;
  final String pays;
  final double temperature; // en degres Celsius
  final String condition; // "Ensoleille", "Nuageux", "Pluvieux"
  final int humidite; // en pourcentage (0-100)
  final String? photoPath; // <- NOUVEAU : chemin vers la photo

  Ville({
    required this.nom,
    required this.pays,
    required this.temperature,
    required this.condition,
    required this.humidite,
    this.photoPath, // optionnel
  });

  // Copier la ville avec une nouvelle photo
  Ville copierAvecPhoto(String chemin) {
    return Ville(
      nom: nom,
      pays: pays,
      temperature: temperature,
      condition: condition,
      humidite: humidite,
      photoPath: chemin,
    );
  }
}

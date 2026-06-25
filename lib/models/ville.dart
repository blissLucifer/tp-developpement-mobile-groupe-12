class Ville {
  final String nom;
  final String pays ;
  final double temperature ; // en degres Celsius
  final String condition ; // " Ensoleille ", " Nuageux ", "Pluvieux "
  final int humidite ; // en pourcentage (0 -100)

  Ville ({
    required this.nom ,
    required this.pays ,
    required this.temperature ,
    required this.condition ,
    required this.humidite ,
  });
}
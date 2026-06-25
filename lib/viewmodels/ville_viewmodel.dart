import 'package:flutter/foundation.dart';
import '../models/ville.dart';

class VilleViewModel extends ChangeNotifier {

  // La liste des villes disponibles
  List<Ville> _villes = [];

  // La ville actuellement selectionnee
  Ville? _villeSelectionnee;

  // Getters (la View lit ces proprietes)
  List<Ville> get villes => _villes;
  Ville? get villeSelectionnee => _villeSelectionnee;

  // Constructeur : charger des donnees au demarrage
  VilleViewModel() {
    _initialiser();
  }

  void _initialiser() {
    _villes = [
      Ville(nom: 'Cotonou', pays: 'Benin', temperature: 29, condition: 'Ensoleille', humidite: 75),
      Ville(nom: 'Parakou', pays: 'Benin', temperature: 32, condition: 'Ensoleille', humidite: 60),
      Ville(nom: 'Lagos', pays: 'Nigeria', temperature: 31, condition: 'Nuageux', humidite: 80),
      Ville(nom: 'Abidjan', pays: 'CI', temperature: 27, condition: 'Pluvieux', humidite: 85),
      Ville(nom: 'Dakar', pays: 'Senegal', temperature: 26, condition: 'Venteux', humidite: 70),
      Ville(nom: 'Lome', pays: 'Togo', temperature: 28, condition: 'Orageux', humidite: 90),
    ];
    _villeSelectionnee = _villes.first;
    notifyListeners(); // prevenir les widgets
  }

  // Changer la ville affichee
  void selectionnerVille(Ville ville) {
    _villeSelectionnee = ville;
    notifyListeners();
  }
  void ajouterVille(Ville ville) {
    _villes.add(ville);
    notifyListeners();
  }

}
import 'package:flutter/foundation.dart';
import '../models/ville.dart';
import '../services/meteo_service.dart';
import '../models/meteo_data.dart';
import '../models/prevision_jour.dart';

class VilleViewModel extends ChangeNotifier {

  List<Ville> _villes = [];
  Ville? _villeSelectionnee;
  final MeteoService _meteoService = MeteoService();
  MeteoData? _meteoActuelle;
  List<PrevisionJour> _previsions = [];
  bool _chargement = false;
  String? _erreur;

  // ① Cache ajouté ici
  final Map<String, (MeteoData, DateTime)> _cache = {};

  List<Ville> get villes => _villes;
  Ville? get villeSelectionnee => _villeSelectionnee;
  MeteoData? get meteoActuelle => _meteoActuelle;
  List<PrevisionJour> get previsions => _previsions;
  bool get chargement => _chargement;
  String? get erreur => _erreur;

  VilleViewModel() {
    _initialiser();
  }

  void _initialiser() {
    _villes = [
      Ville(nom: 'Cotonou',     pays: 'Benin',    temperature: 40, condition: 'Ensoleille', humidite: 75),
      Ville(nom: 'Parakou',     pays: 'Benin',    temperature: 32, condition: 'Ensoleille', humidite: 60),
      Ville(nom: 'Lagos',       pays: 'Nigeria',  temperature: 31, condition: 'Nuageux',    humidite: 80),
      Ville(nom: 'Abidjan',     pays: 'CI',       temperature: 27, condition: 'Pluvieux',   humidite: 85),
      Ville(nom: 'Dakar',       pays: 'Senegal',  temperature: 26, condition: 'Venteux',    humidite: 70),
      Ville(nom: 'Avrankou',    pays: 'Benin',    temperature: 16, condition: 'Nuageux',    humidite: 75),
      Ville(nom: 'Lome',        pays: 'Togo',     temperature: 28, condition: 'Orageux',    humidite: 90),
      Ville(nom: 'Accra',       pays: 'Ghana',    temperature: 30, condition: 'Nuageux',    humidite: 78),
      Ville(nom: 'Bamako',      pays: 'Mali',     temperature: 38, condition: 'Ensoleille', humidite: 25),
      Ville(nom: 'Niamey',      pays: 'Niger',    temperature: 41, condition: 'Ensoleille', humidite: 18),
      Ville(nom: 'Ouagadougou', pays: 'Burkina',  temperature: 39, condition: 'Venteux',    humidite: 22),
      Ville(nom: 'Douala',      pays: 'Cameroun', temperature: 27, condition: 'Pluvieux',   humidite: 90),
      Ville(nom: 'Kinshasa',    pays: 'Congo',    temperature: 26, condition: 'Orageux',    humidite: 88),
      Ville(nom: 'Abuja',       pays: 'Nigeria',  temperature: 33, condition: 'Nuageux',    humidite: 55),
      Ville(nom: 'Natitingou',  pays: 'Bénin',    temperature: 40, condition: 'Venteux',    humidite: 56),
      Ville(nom: 'Dassa',       pays: 'Bénin',    temperature: 56, condition: 'Venteux',    humidite: 44),
    ];
    _villeSelectionnee = _villes.first;
    notifyListeners();
  }

  // ② Méthode de vérification du cache ajoutée ici
  bool _cacheValide(String nomVille) {
    if (!_cache.containsKey(nomVille)) return false;
    final age = DateTime.now().difference(_cache[nomVille]!.$2);
    return age.inMinutes < 30;
  }

  Future<void> selectionnerVille(Ville ville) async {
    _villeSelectionnee = ville;
    _erreur = null;

    // ③ Vérification du cache avant d'appeler l'API
    if (_cacheValide(ville.nom)) {
      _meteoActuelle = _cache[ville.nom]!.$1;
      notifyListeners();
      return;
    }

    _chargement = true;
    notifyListeners();

    final results = await Future.wait([
      _meteoService.getMeteo(ville.nom),
      _meteoService.getPrevisions(ville.nom),
    ]);

    final meteo = results[0] as MeteoData?;
    final prevs = results[1] as List<PrevisionJour>;

    if (meteo != null) {
      _meteoActuelle = meteo;
      _previsions    = prevs;
      _cache[ville.nom] = (meteo, DateTime.now());
    } else {
      _erreur = 'Impossible de charger la météo';
    }
    _chargement = false;
    notifyListeners();
  }

  void ajouterVille(Ville ville) {
    _villes.add(ville);
    notifyListeners();
  }
}
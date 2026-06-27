import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
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

  bool _cacheValide(String nomVille) {
    if (!_cache.containsKey(nomVille)) return false;
    final age = DateTime.now().difference(_cache[nomVille]!.$2);
    return age.inMinutes < 30;
  }

  Future<void> selectionnerVille(Ville ville) async {
    _villeSelectionnee = ville;
    _erreur = null;

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

      // Verifier si la temperature depasse le seuil d'alerte
      await _verifierAlerteChaleur();

      // Planifier la notification quotidienne
      try {
        await planifierNotificationQuotidienne();
      } catch (e) {
        print('Erreur notification planifiée : $e');
      }
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

  // Mettre a jour la photo de la ville selectionnee
  void mettreAJourPhoto(String cheminPhoto) {
    if (_villeSelectionnee == null) return;

    // Trouver l'index de la ville dans la liste
    final index = _villes.indexWhere((v) => v.nom == _villeSelectionnee!.nom);
    if (index == -1) return;

    // Creer une copie avec la nouvelle photo
    _villes[index] = _villes[index].copierAvecPhoto(cheminPhoto);
    _villeSelectionnee = _villes[index];

    notifyListeners(); // prevenir les widgets
  }

  // Dans le ViewModel, apres avoir charge la meteo :
  Future<void> _verifierAlerteChaleur() async {
    if (_meteoActuelle == null) return;
    if (_meteoActuelle!.temperature > 33) {
      final plugin = FlutterLocalNotificationsPlugin();

      // Initialisation obligatoire avant show()
      const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
      await plugin.initialize(
        InitializationSettings(android: androidSettings),
      );

      const AndroidNotificationDetails details = AndroidNotificationDetails(
        'canal_alerte', 'Alertes Meteo',
        importance: Importance.high, priority: Priority.high,
      );

      await plugin.show(
        1,
        'Alerte chaleur !',
        'Il fait ${_meteoActuelle!.temperature.toStringAsFixed(0)}°C à ${_villeSelectionnee!.nom}',
        NotificationDetails(android: details),
      );
    }
  }

  // Exercice C : notification planifiée exactement à 7h00 chaque matin
  Future<void> planifierNotificationQuotidienne() async {
    final plugin = FlutterLocalNotificationsPlugin();

    // Initialisation
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    await plugin.initialize(
      InitializationSettings(android: androidSettings),
    );

    // Initialiser les fuseaux horaires
    tz_data.initializeTimeZones();
    final location = tz.getLocation('Africa/Porto-Novo'); // fuseau Bénin

    // Calculer le prochain 7h00
    final maintenant = tz.TZDateTime.now(location);
    var prochain7h = tz.TZDateTime(location,
        maintenant.year, maintenant.month, maintenant.day, 7, 0, 0);

    // Si 7h00 est déjà passé aujourd'hui, on planifie pour demain
    if (prochain7h.isBefore(maintenant)) {
      prochain7h = prochain7h.add(Duration(days: 1));
    }

    const AndroidNotificationDetails details = AndroidNotificationDetails(
      'canal_quotidien', 'Météo Quotidienne',
      importance: Importance.high,
      priority: Priority.high,
    );

    // Annuler l'ancienne planification avant d'en créer une nouvelle
    await plugin.cancel(2);

    // Planifier la notification à 7h00 chaque jour
    await plugin.zonedSchedule(
      2,
      'Météo du jour ☀️',
      _villeSelectionnee != null
          ? 'Bonjour ! Météo à ${_villeSelectionnee!.nom} : ${_meteoActuelle?.conditionTexte ?? "chargement..."}'
          : 'Bonjour ! Consultez la météo du jour.',
      prochain7h,
      NotificationDetails(android: details),
      androidScheduleMode: AndroidScheduleMode.inexact, // inexact pour éviter l'erreur Android 12+
      matchDateTimeComponents: DateTimeComponents.time, // répète chaque jour à la même heure
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
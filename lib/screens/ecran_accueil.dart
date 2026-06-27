import 'package:flutter/material.dart';
import 'ecran_detail_ville.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../viewmodels/ville_viewmodel.dart';
import '../services/localisation_service.dart';
import '../services/meteo_service.dart';
import 'ecran_liste_villes.dart';

class EcranAccueil extends StatefulWidget {
  const EcranAccueil({super.key});

  @override
  State<EcranAccueil> createState() => _EcranAccueilState();
}

// Etape 1 : ajout de SingleTickerProviderStateMixin pour AnimatedOpacity
class _EcranAccueilState extends State<EcranAccueil>
    with SingleTickerProviderStateMixin {
  // Etape 1 : booléen qui contrôle la visibilité au démarrage
  bool _visible = false;

  // Controller pour la rotation du soleil
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    // Demarrer l'animation apres 500 ms
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) setState(() => _visible = true);
    });

    // Initialiser le controller (1 tour toutes les 8 secondes)
    _rotationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 8),
    );
  }

  // Exercice C : libérer le controller pour eviter les memory leaks
  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  IconData _iconeMeteo(String condition) {
    switch (condition) {
      case 'Ensoleille':
        return Icons.wb_sunny;
      case 'Nuageux':
        return Icons.cloud;
      case 'Pluvieux':
        return Icons.umbrella;
      case 'Orageux':
        return Icons.umbrella_outlined;
      case 'Venteux':
        return Icons.air;
      case 'Neigeux':
        return Icons.air;
      default:
        return Icons.wb_cloudy;
    }
  }

  Color _couleurFond(String condition) {
    switch (condition) {
      case 'Ensoleille':
        return Colors.orange.shade100;
      case 'Nuageux':
        return Colors.grey.shade200;
      case 'Pluvieux':
        return Colors.blue.shade100;
      case 'Orageux':
        return Colors.purple.shade100;
      case 'Venteux':
        return Colors.teal.shade100;
      case 'Neigeux':
        return Colors.lightGreenAccent;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VilleViewModel>();
    final ville = vm.villeSelectionnee;

    // Exercice C : démarrer ou arrêter la rotation selon la condition météo
    if (ville?.condition == 'Ensoleille') {
      if (!_rotationController.isAnimating) _rotationController.repeat();
    } else {
      if (_rotationController.isAnimating) {
        _rotationController.stop();
        _rotationController.reset();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('AppMeteo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      // Etape 1 : AnimatedOpacity enveloppe tout le body
      body: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: Duration(milliseconds: 1200),
        curve: Curves.easeIn,
        child: ville == null
            ? Center(child: CircularProgressIndicator(color: Colors.yellow))
            // AnimatedContainer anime la couleur de fond selon la temperature
            : AnimatedContainer(
                duration: Duration(milliseconds: 800),
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: () {
                    final temp = vm.meteoActuelle?.temperature ?? 0;
                    if (temp < 20)
                      return Colors.blue.shade100; // T < 20°C : frais
                    if (temp < 30)
                      return Colors
                          .orange
                          .shade100; // 20°C <= T < 30°C : tempere
                    return Colors.red.shade100; // T >= 30°C : chaud
                  }(),
                ),
                // SingleChildScrollView pour eviter le debordement sur petits ecrans
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 24),

                      // Navigation vers l'écran de détail au tap sur le Hero + infos meteo
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EcranDetailVille(
                                ville: vm.villeSelectionnee!,
                                meteo: vm.meteoActuelle,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            //Envelopper l'icone dans Hero
                            Hero(
                              tag:
                                  'icone-${vm.villeSelectionnee?.nom ?? "meteo"}',
                              // Exercice C : RotationTransition autour de l'AnimatedContainer
                              child: RotationTransition(
                                turns: _rotationController,
                                //AnimatedContainer pour animer la taille de l'icone
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.elasticOut,
                                  width:
                                      (vm.meteoActuelle?.temperature ?? 0) > 30
                                      ? 120
                                      : 80,
                                  height:
                                      (vm.meteoActuelle?.temperature ?? 0) > 30
                                      ? 120
                                      : 80,
                                  child: Icon(
                                    _iconeMeteo(
                                      vm.villeSelectionnee?.condition ?? '',
                                    ),
                                    size:
                                        (vm.meteoActuelle?.temperature ?? 0) >
                                            30
                                        ? 120
                                        : 80,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                          ],
                        ),
                      ),

                      Consumer<VilleViewModel>(
                        builder: (context, vm, _) {
                          if (vm.chargement) {
                            return CircularProgressIndicator(
                              color: Colors.yellow,
                            );
                          }
                          if (vm.erreur != null) {
                            return Column(
                              children: [
                                Icon(
                                  Icons.wifi_off,
                                  size: 60,
                                  color: Colors.red,
                                ),
                                Text(
                                  vm.erreur!,
                                  style: TextStyle(color: Colors.red),
                                ),
                                ElevatedButton(
                                  onPressed: () => vm.selectionnerVille(
                                    vm.villeSelectionnee!,
                                  ),
                                  child: Text('Réessayer'),
                                ),
                              ],
                            );
                          }
                          final meteo = vm.meteoActuelle;
                          if (meteo == null) return Text('Chargement...');

                          return Column(
                            children: [
                              // AnimatedSwitcher anime le changement de temperature
                              AnimatedSwitcher(
                                duration: Duration(milliseconds: 400),
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                child: Text(
                                  '${vm.meteoActuelle?.temperature.toStringAsFixed(1) ?? '--'}°C',
                                  key: ValueKey(
                                    vm.villeSelectionnee?.nom,
                                  ), // IMPORTANT : detecte le changement
                                  style: TextStyle(
                                    fontSize: 60,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                meteo.dateMesure,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '${meteo.conditionTexte} - ${meteo.humidite}% humidité',
                              ),
                              SizedBox(height: 24),

                              // ListView horizontale des 3 prochains jours
                              SizedBox(
                                height: 110,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: vm.previsions.length,
                                  itemBuilder: (context, i) {
                                    final p = vm.previsions[i];
                                    return Container(
                                      width: 90,
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            p.jourFormate,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            p.conditionTexte,
                                            style: TextStyle(fontSize: 11),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            '${p.tempMax.toStringAsFixed(0)}° / ${p.tempMin.toStringAsFixed(0)}°',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      Text(
                        ville.nom,
                        style: TextStyle(fontSize: 28, color: Colors.grey[700]),
                      ),

                      // Coordonnées GPS de la ville sélectionnée
                      Builder(
                        builder: (_) {
                          final coords = MeteoService.coords[ville.nom];
                          if (coords == null) return SizedBox.shrink();
                          return Text(
                            'Lat: ${coords[0].toStringAsFixed(4)} | Lon: ${coords[1].toStringAsFixed(4)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: switch (ville.condition) {
                                'Ensoleille' => Colors.deepOrange,
                                'Nuageux' => Colors.blueGrey,
                                'Pluvieux' => Colors.blueAccent,
                                'Orageux' => Colors.indigo,
                                'Venteux' => Colors.teal,
                                'Neigeux' => Colors.lightBlue,
                                _ => Colors.grey,
                              },
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 32),

                      // Ajouter dans le body de EcranAccueil :
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: GestureDetector(
                          onTap: () async {
                            // Afficher le choix : galerie ou appareil photo
                            final source =
                                await showModalBottomSheet<ImageSource>(
                                  context: context,
                                  builder: (ctx) => SafeArea(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: Icon(Icons.photo_library),
                                          title: Text('Galerie'),
                                          onTap: () => Navigator.pop(
                                            ctx,
                                            ImageSource.gallery,
                                          ),
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.camera_alt),
                                          title: Text('Appareil photo'),
                                          onTap: () => Navigator.pop(
                                            ctx,
                                            ImageSource.camera,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );

                            if (source == null)
                              return; // l'utilisateur a fermé sans choisir

                            final picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                              source: source,
                            );

                            if (image != null) {
                              // Mettre a jour le ViewModel avec le chemin de la photo
                              context.read<VilleViewModel>().mettreAJourPhoto(
                                image.path,
                              );
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: vm.villeSelectionnee?.photoPath != null
                                ? Image.file(
                                    File(vm.villeSelectionnee!.photoPath!),
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: double.infinity,
                                    height: 200,
                                    color: Colors.grey[200],
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                        Text('Appuyez pour ajouter une photo'),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      SizedBox(height: 16),
                      // Boutons côte à côte : changer de ville et ville la plus proche
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.list),
                                label: Text('Changer de ville'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EcranListeVilles(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.my_location),
                                label: Text('Trouver la ville la plus proche'),
                                onPressed: () async {
                                  final service = LocalisationService();
                                  final position = await service.getPosition();

                                  if (position != null) {
                                    final vm = context.read<VilleViewModel>();
                                    final villeProche = service
                                        .trouverVilleProche(
                                          position,
                                          vm.villes,
                                          MeteoService.coords,
                                        );

                                    if (villeProche != null) {
                                      vm.selectionnerVille(villeProche);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Ville proche : ${villeProche.nom}',
                                          ),
                                        ),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('GPS indisponible'),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

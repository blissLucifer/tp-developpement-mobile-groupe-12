import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/ville_viewmodel.dart';
import 'ecran_liste_villes.dart';

class EcranAccueil extends StatelessWidget {
  const EcranAccueil({super.key});

  IconData _iconeMeteo(String condition) {
    switch (condition) {
      case 'Ensoleille': return Icons.wb_sunny;
      case 'Nuageux':    return Icons.cloud;
      case 'Pluvieux':   return Icons.umbrella;
      case 'Orageux':    return Icons.umbrella_outlined;
      case 'Venteux':    return Icons.air;
      case 'Neigeux':    return Icons.air;
      default:           return Icons.wb_cloudy;
    }
  }

  Color _couleurFond(String condition) {
    switch (condition) {
      case 'Ensoleille': return Colors.orange.shade100;
      case 'Nuageux':    return Colors.grey.shade200;
      case 'Pluvieux':   return Colors.blue.shade100;
      case 'Orageux':    return Colors.purple.shade100;
      case 'Venteux':    return Colors.teal.shade100;
      case 'Neigeux':    return Colors.lightGreenAccent;
      default:           return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VilleViewModel>();
    final ville = vm.villeSelectionnee;

    return Scaffold(
      appBar: AppBar(
        title: Text('AppMeteo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ville == null
          ? Center(child: CircularProgressIndicator())
          : Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: _couleurFond(ville.condition),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                _iconeMeteo(ville.condition),
                size: 100,
                color: Colors.orange,
              ),
              SizedBox(height: 16),
              Consumer<VilleViewModel>(
                builder: (context, vm, _) {
                  if (vm.chargement) {
                    return CircularProgressIndicator();
                  }
                  if (vm.erreur != null) {
                    return Column(children: [
                      Icon(Icons.wifi_off, size: 60, color: Colors.red),
                      Text(vm.erreur!, style: TextStyle(color: Colors.red)),
                      ElevatedButton(
                        onPressed: () => vm.selectionnerVille(vm.villeSelectionnee!),
                        child: Text('Réessayer'),
                      ),
                    ]);
                  }
                  final meteo = vm.meteoActuelle;
                  if (meteo == null) return Text('Chargement...');

                  return Column(children: [
                    Text(
                      '${meteo.temperature.toStringAsFixed(1)}°C',
                      style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      meteo.dateMesure,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    Text('${meteo.conditionTexte} - ${meteo.humidite}% humidité'),
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
                            margin: EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(p.jourFormate, style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text(p.conditionTexte, style: TextStyle(fontSize: 11), textAlign: TextAlign.center),
                                SizedBox(height: 4),
                                Text('${p.tempMax.toStringAsFixed(0)}° / ${p.tempMin.toStringAsFixed(0)}°',
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ]);
                },
              ),
              Text(
                ville.nom,
                style: TextStyle(fontSize: 28, color: Colors.grey[700]),
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
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
            ],
          ),
        ),
      ),
    );
  }
}
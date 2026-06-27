import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/ville_viewmodel.dart';
import '../models/ville.dart';

class EcranAjoutVille extends StatefulWidget {
  const EcranAjoutVille({super.key});

  @override
  State<EcranAjoutVille> createState() => _EcranAjoutVilleState();
}

class _EcranAjoutVilleState extends State<EcranAjoutVille> {
  // Controleurs pour lire ce que l'utilisateur tape
  final _nomController = TextEditingController();
  final _paysController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _humiditeController = TextEditingController();

  // Condition selectionnee dans la liste deroulante
  String _conditionSelectionnee = 'Ensoleille';

  // Liste des conditions disponibles
  final List<String> _conditions = [
    'Ensoleille',
    'Nuageux',
    'Pluvieux',
    'Orageux',
    'Venteux',
    'Neigeux',
  ];

  void _valider() {
    // Verifier que les champs ne sont pas vides
    if (_nomController.text.isEmpty ||
        _paysController.text.isEmpty ||
        _temperatureController.text.isEmpty ||
        _humiditeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    // Creer la nouvelle ville
    final nouvelleVille = Ville(
      nom: _nomController.text,
      pays: _paysController.text,
      temperature: double.parse(_temperatureController.text),
      condition: _conditionSelectionnee,
      humidite: int.parse(_humiditeController.text),
    );

    // Ajouter la ville via le ViewModel
    context.read<VilleViewModel>().ajouterVille(nouvelleVille);

    // Revenir a l'ecran precedent
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une ville'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nomController,
              decoration: InputDecoration(
                labelText: 'Nom de la ville',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _paysController,
              decoration: InputDecoration(
                labelText: 'Pays',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _temperatureController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Température (°C)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.thermostat),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _humiditeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Humidité (%)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.water_drop),
              ),
            ),
            SizedBox(height: 16),
            // Liste deroulante pour la condition
            DropdownButtonFormField<String>(
              value: _conditionSelectionnee,
              decoration: InputDecoration(
                labelText: 'Condition météo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cloud),
              ),
              items: _conditions.map((condition) {
                return DropdownMenuItem(
                  value: condition,
                  child: Text(condition),
                );
              }).toList(),
              onChanged: (valeur) {
                setState(() {
                  _conditionSelectionnee = valeur!;
                });
              },
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.check),
                label: Text('Ajouter la ville'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _valider,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

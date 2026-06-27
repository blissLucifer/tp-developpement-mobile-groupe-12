import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/ville_viewmodel.dart';
import '../models/ville.dart';
import 'ecran_ajout_ville.dart';

class EcranListeVilles extends StatelessWidget {
  const EcranListeVilles({super.key});

  @override
  Widget build(BuildContext context) {
    // On lit la liste des villes depuis le ViewModel
    final vm = context.watch<VilleViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Choisir une ville'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      // Bouton flottant pour acceder au formulaire d'ajout
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add),
        label: Text('Ajouter une ville'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EcranAjoutVille()),
          );
        },
      ),
      body: ListView.builder(
        itemCount: vm.villes.length,
        itemBuilder: (context, index) {
          final ville = vm.villes[index];
          final estSelectionnee = ville.nom == vm.villeSelectionnee?.nom;

          return ListTile(
            leading: Icon(
              Icons.location_city,
              color: estSelectionnee ? Colors.blue : Colors.grey,
            ),
            title: Text(
              ville.nom,
              style: TextStyle(
                fontWeight: estSelectionnee
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            subtitle: Text('${ville.pays} - ${ville.temperature}°C'),
            trailing: estSelectionnee
                ? Icon(Icons.check_circle, color: Colors.blue)
                : null,
            onTap: () {
              // Utiliser context.read() pour appeler une action
              context.read<VilleViewModel>().selectionnerVille(ville);
              Navigator.pop(context); // revenir a l'ecran precedent
            },
          );
        },
      ),
    );
  }
}

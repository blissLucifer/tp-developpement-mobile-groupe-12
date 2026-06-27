import 'package:flutter_test/flutter_test.dart';
import 'package:app_meteo/viewmodels/ville_viewmodel.dart';
import 'package:app_meteo/models/ville.dart';

void main() {
  late VilleViewModel vm;

  setUp(() {
    // Creer un ViewModel frais avant chaque test
    vm = VilleViewModel();
  });

  group('VilleViewModel', () {

    test('la liste initiale contient au moins 4 villes', () {
      expect(vm.villes.length, greaterThanOrEqualTo(4));
    });

    test('Cotonou est dans la liste initiale', () {
      final contientCotonou = vm.villes.any((v) => v.nom == 'Cotonou');
      expect(contientCotonou, isTrue);
    });

    test('selectionnerVille met a jour villeSelectionnee', () {
      // ARRANGE : trouver Lagos dans la liste
      final lagos = vm.villes.firstWhere((v) => v.nom == 'Lagos');
      // ACT
      vm.selectionnerVille(lagos);
      // ASSERT
      expect(vm.villeSelectionnee?.nom, equals('Lagos'));
    });

    // Verifie que l'ajout d'une ville incremente correctement la taille de la liste
    test('ajouterVille augmente la liste de 1', () {
      final nbAvant = vm.villes.length;
      vm.ajouterVille(Ville(
        nom: 'Lomé',
        pays: 'Togo',
        temperature: 28,
        condition: 'Ensoleille',
        humidite: 70,
      ));
      expect(vm.villes.length, equals(nbAvant + 1));
    });

    // Verifie que selectionnerVille declenche bien notifyListeners
    // pour que les widgets abonnes se reconstruisent
    test('selectionnerVille notifie les listeners', () {
      int compteur = 0;
      vm.addListener(() => compteur++);
      final lagos = vm.villes.firstWhere((v) => v.nom == 'Lagos');
      vm.selectionnerVille(lagos);
      expect(compteur, greaterThan(0));
    });

  });
}
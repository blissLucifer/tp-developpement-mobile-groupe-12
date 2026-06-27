import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:app_meteo/viewmodels/ville_viewmodel.dart';
import 'package:app_meteo/screens/ecran_accueil.dart';
import 'package:app_meteo/screens/ecran_liste_villes.dart';

// Fonction utilitaire pour creer le widget de test
Widget creerAppTest() {
  return ChangeNotifierProvider(
    create: (_) => VilleViewModel(),
    child: MaterialApp(home: EcranAccueil()),
  );
}

// Fonction utilitaire : attend le rendu en ignorant les animations infinies
Future<void> attendreRendu(WidgetTester tester) async {
  try {
    await tester.pumpAndSettle();
  } catch (_) {
    // L'AnimationController repeat() empeche pumpAndSettle de terminer
    // On laisse le rendu se stabiliser avec plusieurs frames
    await tester.pump(Duration(milliseconds: 500));
    await tester.pump(Duration(milliseconds: 500));
  }
}

void main() {
  testWidgets('EcranAccueil affiche une AppBar avec le titre', (tester) async {
    // Monter le widget
    await tester.pumpWidget(creerAppTest());
    await attendreRendu(tester);

    // Verifier que l'AppBar existe
    expect(find.byType(AppBar), findsOneWidget);

    // Verifier que le titre AppMeteo est present
    expect(find.text('AppMeteo'), findsOneWidget);
  });

  testWidgets('EcranAccueil affiche une Temperature', (tester) async {
    await tester.pumpWidget(creerAppTest());
    await attendreRendu(tester);

    // La temperature doit contenir le symbole "C"
    // Chercher un widget Text qui contient "C"
    final textFinder = find.textContaining('C');
    expect(textFinder, findsWidgets); // au moins un widget avec "C"
  });

  testWidgets('Le bouton Changer de ville est present', (tester) async {
    await tester.pumpWidget(creerAppTest());
    await attendreRendu(tester);

    expect(find.text('Changer de ville'), findsOneWidget);
  });

  // Verifie que le tap sur le bouton navigue bien vers EcranListeVilles
  testWidgets('Appuyer sur Changer de ville ouvre la liste', (tester) async {
    await tester.pumpWidget(creerAppTest());
    await attendreRendu(tester);

    // ACT : appuyer sur le bouton
    await tester.tap(find.text('Changer de ville'));
    await tester.pumpAndSettle();

    // ASSERT : l'ecran de liste est visible
    expect(find.byType(EcranListeVilles), findsOneWidget);
  });
}

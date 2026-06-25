import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/ville_viewmodel.dart';
import 'screens/ecran_accueil.dart';

void main() {
  runApp(
    // ChangeNotifierProvider place le ViewModel au sommet de l'arbre
    ChangeNotifierProvider(
      create: (_) => VilleViewModel(),
      child: MaterialApp(
        title: 'AppMeteo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: EcranAccueil(),
      ),
    ),
  );
}
import 'package:flutter_test/flutter_test.dart';
import 'package:app_meteo/models/meteo_data.dart';

void main() {
  group('MeteoData', () {
    // Test 1 : fourni
    test('fromJson parse la temperature correctement', () {
      final json = {
        'temperature_2m': 29.5,
        'relative_humidity_2m': 70,
        'weathercode': 0,
        'time': '2026-06-27T10:00',
      };
      final meteo = MeteoData.fromJson(json);
      expect(meteo.temperature, equals(29.5));
    });

    // Test 2 : fourni
    test('conditionTexte retourne Ensoleille pour code 0', () {
      final meteo = MeteoData(
        temperature: 30,
        humidite: 60,
        weatherCode: 0,
        time: '2026-06-27T10:00',
      );
      expect(meteo.conditionTexte, equals('Ensoleillé')); // accent !
    });

    // Test 3 : complété
    test('conditionTexte retourne Pluvieux pour code 61', () {
      final meteo = MeteoData(
        temperature: 25,
        humidite: 80,
        weatherCode: 61,
        time: '2026-06-27T10:00',
      );
      expect(meteo.conditionTexte, equals('Pluvieux'));
    });

    // Test 4 : complété
    test('fromJson parse l humidite correctement', () {
      final json = {
        'temperature_2m': 28.0,
        'relative_humidity_2m': 75,
        'weathercode': 0,
        'time': '2026-06-27T10:00',
      };
      final meteo = MeteoData.fromJson(json);
      expect(meteo.humidite, equals(75));
    });

    // Exercice A : tester tous les codes WMO

    // code 1-3 : Nuageux
    test('conditionTexte retourne Nuageux pour code 1', () {
      // ARRANGE
      final meteo = MeteoData(
        temperature: 28,
        humidite: 60,
        weatherCode: 1,
        time: '2026-06-27T10:00',
      );
      // ACT + ASSERT
      expect(meteo.conditionTexte, equals('Nuageux'));
    });

    test('conditionTexte retourne Nuageux pour code 2', () {
      // ARRANGE
      final meteo = MeteoData(
        temperature: 28,
        humidite: 60,
        weatherCode: 2,
        time: '2026-06-27T10:00',
      );
      // ACT + ASSERT
      expect(meteo.conditionTexte, equals('Nuageux'));
    });

    test('conditionTexte retourne Nuageux pour code 3', () {
      // ARRANGE
      final meteo = MeteoData(
        temperature: 28,
        humidite: 60,
        weatherCode: 3,
        time: '2026-06-27T10:00',
      );
      // ACT + ASSERT
      expect(meteo.conditionTexte, equals('Nuageux'));
    });

    // code 80-82 : Averses
    test('conditionTexte retourne Averses pour code 80', () {
      // ARRANGE
      final meteo = MeteoData(
        temperature: 24,
        humidite: 90,
        weatherCode: 80,
        time: '2026-06-27T10:00',
      );
      // ACT + ASSERT
      expect(meteo.conditionTexte, equals('Averses'));
    });

    test('conditionTexte retourne Averses pour code 81', () {
      // ARRANGE
      final meteo = MeteoData(
        temperature: 24,
        humidite: 90,
        weatherCode: 81,
        time: '2026-06-27T10:00',
      );
      // ACT + ASSERT
      expect(meteo.conditionTexte, equals('Averses'));
    });

    test('conditionTexte retourne Averses pour code 82', () {
      // ARRANGE
      final meteo = MeteoData(
        temperature: 24,
        humidite: 90,
        weatherCode: 82,
        time: '2026-06-27T10:00',
      );
      // ACT + ASSERT
      expect(meteo.conditionTexte, equals('Averses'));
    });

    // code 95+ : Orageux
    test('conditionTexte retourne Orageux pour code 95', () {
      // ARRANGE
      final meteo = MeteoData(
        temperature: 26,
        humidite: 95,
        weatherCode: 95,
        time: '2026-06-27T10:00',
      );
      // ACT + ASSERT
      expect(meteo.conditionTexte, equals('Orageux'));
    });

    test('conditionTexte retourne Orageux pour code 99', () {
      // ARRANGE
      final meteo = MeteoData(
        temperature: 26,
        humidite: 95,
        weatherCode: 99,
        time: '2026-06-27T10:00',
      );
      // ACT + ASSERT
      expect(meteo.conditionTexte, equals('Orageux'));
    });

    // code inconnu : Variable
    test('conditionTexte retourne Variable pour code inconnu', () {
      // ARRANGE
      final meteo = MeteoData(
        temperature: 25,
        humidite: 70,
        weatherCode: 10,
        time: '2026-06-27T10:00',
      );
      // ACT + ASSERT
      expect(meteo.conditionTexte, equals('Variable'));
    });

    // Tester estDangereux()

    // Cas 1 : chaud ET orage -> dangereux
    test('estDangereux retourne true si T > 40 ET orage', () {
      // ARRANGE
      final meteo = MeteoData(
        temperature: 42,
        humidite: 80,
        weatherCode: 95,
        time: '2026-06-27T10:00',
      );
      // ACT + ASSERT
      expect(meteo.estDangereux(), isTrue);
    });

    // Cas 2 : chaud seul -> dangereux
    test('estDangereux retourne true si T > 40 seul', () {
      // ARRANGE
      final meteo = MeteoData(
        temperature: 41,
        humidite: 60,
        weatherCode: 0,
        time: '2026-06-27T10:00',
      );
      // ACT + ASSERT
      expect(meteo.estDangereux(), isTrue);
    });

    // Cas 3 : orage seul -> dangereux
    test('estDangereux retourne true si orage seul', () {
      // ARRANGE
      final meteo = MeteoData(
        temperature: 28,
        humidite: 90,
        weatherCode: 95,
        time: '2026-06-27T10:00',
      );
      // ACT + ASSERT
      expect(meteo.estDangereux(), isTrue);
    });

    // Cas 4 : normal -> pas dangereux
    test('estDangereux retourne false si normal', () {
      // ARRANGE
      final meteo = MeteoData(
        temperature: 30,
        humidite: 70,
        weatherCode: 3,
        time: '2026-06-27T10:00',
      );
      // ACT + ASSERT
      expect(meteo.estDangereux(), isFalse);
    });
  });
}

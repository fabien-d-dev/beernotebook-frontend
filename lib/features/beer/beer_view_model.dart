import 'package:flutter/material.dart';
import 'beer_model.dart';

class BeerViewModel extends ChangeNotifier {
  // Liste privée pour encapsuler les données
  final List<Beer> _beers = [
    Beer(id: '1', name: 'Punk IPA', brewery: 'BrewDog', abv: 5.4, rating: 4.5),
    Beer(id: '2', name: 'Chouffe', brewery: 'Achouffe', abv: 8.0, rating: 4.8),
  ];

  // Getter pour lire les bières sans modifier la liste originale
  List<Beer> get beers => _beers;

  void addBeer(Beer beer) {
    _beers.add(beer);
    notifyListeners(); // C'est CA qui prévient l'UI de se mettre à jour
  }

  void removeBeer(String id) {
    _beers.removeWhere((b) => b.id == id);
    notifyListeners();
  }
}

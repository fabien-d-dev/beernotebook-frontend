import 'package:flutter/material.dart';
import 'beer_model.dart';

class BeerViewModel extends ChangeNotifier {
  // Private list to encapsulate the data (waiting for API connection)
  final List<Beer> _beers = [
    Beer(id: '1', name: 'Punk IPA', brewery: 'BrewDog', abv: 5.4, rating: 4.5),
    Beer(id: '2', name: 'Chouffe', brewery: 'Achouffe', abv: 8.0, rating: 4.8),
  ];

  // Getter to read the beers without modifying the original list
  List<Beer> get beers => _beers;

  void addBeer(Beer beer) {
    _beers.add(beer);
    notifyListeners(); // This is what tells the UI to update
  }

  void removeBeer(String id) {
    _beers.removeWhere((b) => b.id == id);
    notifyListeners();
  }
}

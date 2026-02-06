import 'package:flutter/material.dart';
import 'beer_model.dart';

class BeerViewModel extends ChangeNotifier {
  final List<Beer> _beers = [
    Beer(
      id: '1',
      name: 'Mélusine',
      brewery: 'Brasserie Mélusine',
      type: 'Bio',
      rating: 10.0,
    ),
    Beer(
      id: '2',
      name: 'St Austell Brewery',
      brewery: 'Proper Job',
      type: 'Cornish IPA',
      rating: 10.0,
    ),
    Beer(
      id: '3',
      name: 'Little Atlantique',
      brewery: 'L.A.B',
      type: 'Double IPA',
      rating: 8.6,
    ),
    Beer(
      id: '4',
      name: 'Little Atlantique Zarata',
      brewery: 'L.A.B',
      type: 'Tripe IPA',
      rating: 5,
    ),
  ];

  List<Beer> get beers => _beers;
}

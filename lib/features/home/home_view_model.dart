import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  String get title => "BeerNotebook";
  String get newsTitle => "Actu Bière & Brasseries";
  String get featuredNews =>
      "SFBT: Plus de 172 millions de litres de bière vendus en 2024";
}

import 'package:flutter/material.dart';

class ProfileViewModel extends ChangeNotifier {
  bool get isStandardAccount => true;

  // Stats
  int get collectionCount => 119;
  int get wishlistCount => 37;

  // General Information
  String get username => "Admin";
  String get email => "novenario@pm.dm.am";

  // Subscription
  String get subscriptionType => "Premium";
  String get startDate => "26/11/2024";

  // Renewal
  String get renewalDate => "26/02/2026";
  bool get isAutoRenewal => true;

  // Liste des badges
  List<Map<String, dynamic>> get badges => [
    {
      "name": "Premier Pas",
      "description": "Avoir scanné sa première bière.",
      "progress": 1.0,
      "date": "12/01/2026",
      "icon": Icons.sports_bar,
    },
    {
      "name": "Amateur de IPA",
      "description": "Noter 5 bières de type IPA.",
      "progress": 0.6,
      "date": null,
      "icon": Icons.local_drink,
    },
    {
      "name": "Grand Voyageur",
      "description": "Goûter des bières de 5 pays différents.",
      "progress": 0.2,
      "date": null,
      "icon": Icons.public,
    },
    {
      "name": "Expert",
      "description": "Remplir 50 fiches de dégustation.",
      "progress": 0.1,
      "date": null,
      "icon": Icons.workspace_premium,
    },
  ];
}

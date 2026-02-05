import 'package:flutter/material.dart';

class ProfileViewModel extends ChangeNotifier {
  // Stats
  int get collectionCount => 119;
  int get wishlistCount => 37;

  // General Information
  String get username => "Admin";
  String get email => "novenario@proton.me";

  // Subscription
  String get subscriptionType => "Premium";
  String get startDate => "26/11/2024";

  // Renewal
  String get renewalDate => "26/02/2026";
  bool get isAutoRenewal => true;
}

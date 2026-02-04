import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navigation_view_model.dart';
import '../home/home_view.dart';
import '../beer/beer_view.dart';
import '../profile/profile_view.dart';

class MainNavigationView extends StatelessWidget {
  const MainNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    // On écoute le ViewModel pour l'index actuel
    final navVM = context.watch<NavigationViewModel>();

    // Liste des vues correspondant aux onglets
    final List<Widget> pages = [
      const BeerView(), // Index 0
      const HomeView(), // Index 1
      const ProfileView() // Index 2
    ];

    return Scaffold(
      body: IndexedStack(index: navVM.selectedIndex, children: pages),
      // On utilise NavigationBar au lieu de BottomNavigationBar
      bottomNavigationBar: NavigationBar(
        selectedIndex: navVM.selectedIndex,
        onDestinationSelected: (int index) {
          // On appelle notre ViewModel au lieu de faire un setState local
          navVM.setIndex(index);
        },
        indicatorColor: const Color.fromARGB(255, 153, 255, 170),
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.sports_bar),
            icon: Icon(Icons.sports_bar_outlined),
            label: 'Bières',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Accueil',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

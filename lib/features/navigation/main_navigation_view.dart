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
    // We listen to the ViewModel for the current index
    final navVM = context.watch<NavigationViewModel>();

    // List of views corresponding to the tabs
    final List<Widget> pages = [
      const BeerView(), // Index 0
      const HomeView(), // Index 1
      const ProfileView() // Index 2
    ];

    return Scaffold(
      body: IndexedStack(index: navVM.selectedIndex, children: pages),
      // We use NavigationBar instead of BottomNavigationBar
      bottomNavigationBar: NavigationBar(
        selectedIndex: navVM.selectedIndex,
        onDestinationSelected: (int index) {
          // We call our ViewModel instead of doing a local setState
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

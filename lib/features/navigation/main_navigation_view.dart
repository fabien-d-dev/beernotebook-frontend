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
    final navVM = context.watch<NavigationViewModel>();

    final List<Widget> pages = [
      const BeerView(),
      const HomeView(),
      const ProfileView(),
    ];

    return Scaffold(
      body: IndexedStack(index: navVM.selectedIndex, children: pages),

      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          // Text Selected
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(
              color: Color.fromARGB(255, 66, 66, 66),
              fontWeight: FontWeight.w500,
            ),
          ),
          // Icon selected
          iconTheme: WidgetStateProperty.all(
            const IconThemeData(color: Color.fromARGB(255, 30, 30, 30)),
          ),
        ),

        child: NavigationBar(
          backgroundColor: Colors.white,
          selectedIndex: navVM.selectedIndex,
          onDestinationSelected: (int index) => navVM.setIndex(index),
          indicatorColor: const Color.fromARGB(255, 176, 238, 255),

          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.sports_bar),
              icon: Icon(
                Icons.sports_bar_outlined,
                color: Color.fromARGB(255, 56, 56, 56),
              ),
              label: 'Bières',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(
                Icons.home_outlined,
                color: Color.fromARGB(255, 56, 56, 56),
              ),
              label: 'Accueil',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.person),
              icon: Icon(
                Icons.person_outline,
                color: Color.fromARGB(255, 56, 56, 56),
              ),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

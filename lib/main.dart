import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/navigation/navigation_view_model.dart';
import 'features/beer/beer_view_model.dart';
import 'features/home/home_view_model.dart';
import 'features/profile/profile_view_model.dart';
import 'features/navigation/main_navigation_view.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationViewModel()),
        ChangeNotifierProvider(create: (_) => BeerViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
      ],
      child: const BeerNotebookApp(),
    ),
  );
}

class BeerNotebookApp extends StatelessWidget {
  const BeerNotebookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beernotebook',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Quicksand',

        // APP BAR
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,

          shape: Border(bottom: BorderSide(color: Color.fromRGBO(243, 242, 247, 1), width: 1)),

          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontFamily: 'Quicksand',
          ),
        ),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 255, 255, 255),
        ),
        useMaterial3: true,
      ),
      home: const MainNavigationView(),
    );
  }
}

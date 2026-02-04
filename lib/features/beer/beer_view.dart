import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'beer_view_model.dart';

class BeerView extends StatelessWidget {
  const BeerView({super.key});

  @override
  Widget build(BuildContext context) {
    final beerVM = context.watch<BeerViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Mes Bières")),
      body: ListView.builder(
        itemCount: beerVM.beers.length,
        itemBuilder: (context, index) {
          final beer = beerVM.beers[index];
          return ListTile(title: Text(beer.name), subtitle: Text(beer.brewery));
        },
      ),
    );
  }
}

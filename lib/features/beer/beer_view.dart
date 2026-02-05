import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'beer_view_model.dart';

class BeerView extends StatelessWidget {
  const BeerView({super.key});

  @override
  Widget build(BuildContext context) {
    final beerVM = context.watch<BeerViewModel>();

    return Scaffold(
      backgroundColor: const Color(
        0xFFF3F2F7,
      ), // Very light grey background as in the image
      appBar: AppBar(
        title: const Text(
          "Collection",
          style: TextStyle(fontFamily: 'Bauhaus', fontSize: 28),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Top button bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: _buildHeaderButton(
                    "Tri: Note",
                    const Color(0xFF0097A7),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildHeaderButton(
                    "Liste de souhaits",
                    const Color(0xFF689F38),
                  ),
                ),
              ],
            ),
          ),

          // Beer list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: beerVM.beers.length,
              itemBuilder: (context, index) {
                final beer = beerVM.beers[index];
                return _buildBeerCard(beer);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget for the top buttons
  Widget _buildHeaderButton(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  // Widget for each beer line
  Widget _buildBeerCard(beer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(30, 0, 0, 0).withValues(),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image of the beer (Placeholder here)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.sports_bar, color: Color(0xFF0097A7)),
          ),
          const SizedBox(width: 15),
          // Text information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  beer.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  beer.type ??
                      "Style inconnu",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          // Rating and Star
          Row(
            children: [
              Text(
                beer.rating.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.star, color: Colors.amber, size: 24),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SubscriptionView extends StatelessWidget {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Retour Profil",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontFamily: 'Quicksand',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- Bloc Avantages Premium ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFF0097A7), width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    "✨ Avantages Premium ✨",
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Quicksand',
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildBenefitRow(
                    "Profitez de l'accès à toutes les fonctionnalités 😎",
                  ),
                  _buildBenefitRow("Pas de limite au nombre de bières ♾️"),
                  _buildBenefitRow(
                    "Enrichissez la base de données en ajoutant les bières non référencées",
                  ),
                  _buildBenefitRow(
                    "Ajoutez vos propres photos de bière dans la bibliothèque commune 📷",
                  ),
                  _buildBenefitRow(
                    "Partagez vos bières avec vos amis grâce à la fonction code-barres 🍻",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- Bloc Prix ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFF0097A7), width: 2),
              ),
              child: Column(
                children: const [
                  Text(
                    "Premium 1,99 € par mois",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Quicksand',
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Sans engagement",
                    style: TextStyle(fontSize: 16, fontFamily: 'Quicksand'),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Stopper quand vous voulez",
                    style: TextStyle(fontSize: 16, fontFamily: 'Quicksand'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- Texte de réassurance ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.arrow_downward, color: Color(0xFF4DB6AC)),
                SizedBox(width: 10),
                Text(
                  "Simple et immédiat",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Quicksand',
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.arrow_downward, color: Color(0xFF4DB6AC)),
              ],
            ),

            const SizedBox(height: 25),

            // --- Bouton Paiement ---
            SizedBox(
              width: double.infinity,
              height: 65,
              child: FilledButton(
                onPressed: () {
                  // Action de paiement
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0097A7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.credit_card, size: 30),
                    SizedBox(width: 15),
                    Text(
                      "Paiement sécurisé",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper pour construire les lignes d'avantages avec la puce verte
  Widget _buildBenefitRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Icon(Icons.circle, size: 8, color: Color(0xFF4DB6AC)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.3,
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

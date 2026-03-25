import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_view_model.dart';
import 'subscription_view_model.dart';
import 'checkout_view.dart';

class SubscriptionView extends StatelessWidget {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    final subVM = context.watch<SubscriptionViewModel>();
    final authVM = context.read<AuthViewModel>();

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
          "Retour",
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
            // Premium Benefits Block
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

            // Price Block
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

            // Reassurance text
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

            // Payment Button
            SizedBox(
              width: double.infinity,
              height: 65,
              child: FilledButton(
                onPressed: subVM.isLoading
                    ? null
                    : () async {
                        final currentId = authVM.userId;

                        if (currentId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Erreur: Utilisateur non identifié",
                              ),
                            ),
                          );
                          return;
                        }

                        // Get the Stripe URL using the ID
                        final url = await subVM.getPaymentUrl(currentId);

                        if (url != null && context.mounted) {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutView(url: url),
                            ),
                          );

                          if (result == 'success' && context.mounted) {
                            await authVM.checkSubscriptionStatus();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Félicitations, vous êtes Premium !",
                                ),
                              ),
                            );
                          }
                        }
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0097A7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                ),
                child: subVM.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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

  // Helper
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profile_view_model.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final profileVM = context.watch<ProfileViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F2F7),
      appBar: AppBar(
        title: const Text(
          "Profil",
          style: TextStyle(
            fontFamily: 'Bauhaus',
            // fontWeight: FontWeight.bold,
            fontSize: 28
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Yellow Header with Counters
            Container(
              color: const Color(0xFFF6D365),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(
                    "Collection",
                    profileVM.collectionCount.toString(),
                  ),
                  _buildStatItem(
                    "Wishlist",
                    profileVM.wishlistCount.toString(),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Informations générales"),
                  _buildInfoBox([
                    _buildInfoRow("Nom d'utilisateur", profileVM.username),
                    const Divider(),
                    _buildInfoRow("E-mail", profileVM.email),
                  ]),

                  _buildSectionTitle("Abonnement"),
                  _buildInfoBox([
                    _buildInfoRow("Type", profileVM.subscriptionType),
                    const Divider(),
                    _buildInfoRow("Date de début", profileVM.startDate),
                  ]),

                  _buildSectionTitle("Renouvellement"),
                  _buildInfoBox([
                    _buildInfoRow("Date", profileVM.renewalDate),
                    const Divider(),
                    _buildInfoRow(
                      "Automatique",
                      profileVM.isAutoRenewal ? "Activé" : "Désactivé",
                    ),
                  ]),

                  const SizedBox(height: 30),

                  // Cancel button (Red)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFD35252),
                      ),
                      child: const Text(
                        "Annuler abonnement",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Options button (Cyan)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0097A7),
                      ),
                      child: const Text(
                        "Options",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoBox(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

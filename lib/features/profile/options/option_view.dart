import 'package:flutter/material.dart';
import './about/about_view.dart';

class OptionsView extends StatelessWidget {
  const OptionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Retour Profil",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "OPTIONS",
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 24,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 30),

          // Options
          _buildOptionItem(
            icon: Icons.info_outline,
            label: "À propos",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (builder) => const AboutView()),
              );
            },
          ),
          _buildOptionItem(
            icon: Icons.delete_outline,
            label: "Supprimer le compte",
            color: const Color(0xFFD35252),
            onTap: () => debugPrint("Action: Supprimer"),
          ),
          _buildOptionItem(
            icon: Icons.logout,
            label: "Déconnexion",
            color: const Color(0xFFD35252),
            onTap: () => debugPrint("Action: Déconnexion"),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.black87,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: color, size: 28),
          title: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: onTap,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(height: 1),
        ),
      ],
    );
  }
}

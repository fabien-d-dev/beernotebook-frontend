import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profile_view_model.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final profileVM = context.watch<ProfileViewModel>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            profileVM.welcomeMessage,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          
          // Saut a la ligne pour le debug
          const SizedBox(height: 20),

          // Bouton Material 3 principal (Rempli)
          FilledButton.icon(
            onPressed: () {
              debugPrint("Action: Go to -> Options");
            },
            // icon: const Icon(Icons.edit),
            label: const Text("Options"),
          ),

          // Saut a la ligne pour le debug
          const SizedBox(height: 12),
          // Bouton Material 3 secondaire (Bordure uniquement)
          OutlinedButton(
            onPressed: () {
              debugPrint("Action: Déconnexion");
            },
            child: const Text("Se déconnecter"),
          ),
        ],
      ),
    );
  }
}

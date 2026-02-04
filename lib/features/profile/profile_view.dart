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
          
          // Line break for debugging
          const SizedBox(height: 20),

          // Main Material 3 button (Filled)
          FilledButton.icon(
            onPressed: () {
              debugPrint("Action: Go to -> Options");
            },
            // icon: const Icon(Icons.edit),
            label: const Text("Options"),
          ),

          // Line break for debugging
          const SizedBox(height: 12),
          // Secondary Material 3 button (Border only)
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

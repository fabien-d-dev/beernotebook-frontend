import 'package:flutter/material.dart';
import 'auth_view_model.dart';
import 'package:provider/provider.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
  
    final authVM = context.watch<AuthViewModel>();

    if (authVM.userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/main');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Beer Notebook",
                style: TextStyle(fontFamily: 'Bauhaus', fontSize: 40),
              ),
              const SizedBox(height: 20),
              Image.asset('assets/images/beer_logo.png', height: 180),
              const SizedBox(height: 30),
              const Text(
                "VOTRE CAVE DIGITALE",
                style: TextStyle(
                  letterSpacing: 1.5,
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 50),
              _buildButton(context, "Se connecter", '/login'),
              const SizedBox(height: 15),
              _buildButton(context, "S'inscrire", '/register'),
              const SizedBox(height: 40),
              const Text(
                "Politique de Confidentialité",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, String route) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, route),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0097A7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

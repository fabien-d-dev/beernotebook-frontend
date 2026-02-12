import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_view_model.dart';

enum ForgotPasswordStep { email, code, update }

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  ForgotPasswordStep _currentStep = ForgotPasswordStep.email;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Image.asset('assets/images/beer_logo.png', height: 120),

            Text(
              _getTitle(),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            if (_currentStep == ForgotPasswordStep.email)
              _buildEmailStep(authVM),
            if (_currentStep == ForgotPasswordStep.code) _buildCodeStep(authVM),
            if (_currentStep == ForgotPasswordStep.update)
              _buildUpdateStep(authVM),

            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Retour à la connexion",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (_currentStep) {
      case ForgotPasswordStep.email:
        return "Mot de passe oublié";
      case ForgotPasswordStep.code:
        return "Vérification du code";
      case ForgotPasswordStep.update:
        return "Nouveau mot de passe";
    }
  }

  //  STEP 1
  Widget _buildEmailStep(AuthViewModel authVM) {
    return Column(
      children: [
        const Text(
          "Veuillez entrer votre adresse e-mail ci-dessous.\nUn code de confirmation vous sera envoyé.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 30),
        _buildTextField("E-mail", controller: _emailController),
        const SizedBox(height: 30),
        _buildActionButton(
          label: "Envoyer le code",
          isLoading: authVM.isLoading,
          onPressed: () => _handleRequestCode(authVM),
        ),
      ],
    );
  }

  //  STEP 2
  Widget _buildCodeStep(AuthViewModel authVM) {
    return Column(
      children: [
        Text(
          "Code envoyé à ${_emailController.text}",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 30),
        _buildTextField(
          "Code à 6 chiffres",
          controller: _codeController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 30),
        _buildActionButton(
          label: "Valider le code",
          isLoading: authVM.isLoading,
          onPressed: () => _handleValidateCode(authVM),
        ),
      ],
    );
  }

  //  STEP 3
  Widget _buildUpdateStep(AuthViewModel authVM) {
    return Column(
      children: [
        const Text(
          "Définissez votre nouveau mot de passe.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 30),
        _buildTextField(
          "Nouveau mot de passe",
          controller: _passwordController,
          obscureText: true,
        ),
        const SizedBox(height: 30),
        _buildActionButton(
          label: "Mettre à jour",
          isLoading: authVM.isLoading,
          onPressed: () => _handleUpdatePassword(authVM),
        ),
      ],
    );
  }

  void _handleRequestCode(AuthViewModel authVM) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    try {
      await authVM.requestPasswordReset(email);
      setState(() => _currentStep = ForgotPasswordStep.code);
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _handleValidateCode(AuthViewModel authVM) async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    try {
      await authVM.validateResetCode(_emailController.text.trim(), code);
      setState(() => _currentStep = ForgotPasswordStep.update);
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _handleUpdatePassword(AuthViewModel authVM) async {
    final pass = _passwordController.text.trim();
    if (pass.length < 6) {
      _showError("Le mot de passe doit faire au moins 6 caractères");
      return;
    }
    try {
      await authVM.updatePassword(pass);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Mot de passe modifié avec succès !"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // UI HELPERS
  Widget _buildTextField(
    String label, {
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0097A7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

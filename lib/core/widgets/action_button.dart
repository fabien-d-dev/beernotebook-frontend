import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final String loadingLabel;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback? onPressed;

  const ActionButton({
    super.key,
    required this.label,
    this.loadingLabel = "Chargement...",
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dynamicWidth = screenWidth * 0.9;

    return SizedBox(
      width: dynamicWidth,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(icon, color: Colors.white),
        label: Text(
          isLoading ? loadingLabel : label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: color.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}

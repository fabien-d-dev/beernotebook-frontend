import 'package:flutter/material.dart';

class RatingSection extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onRatingChanged;

  const RatingSection({
    super.key,
    required this.rating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Note globale",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ), 
          child: Slider(
            value: rating,
            min: 0,
            max: 10,
            divisions: 100,
            activeColor: const Color(0xFF4CAF50),
            onChanged: onRatingChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCircleBtn(
              Icons.remove,
              () => onRatingChanged((rating - 0.1).clamp(0.0, 10.0)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildCircleBtn(
              Icons.add,
              () => onRatingChanged((rating + 0.1).clamp(0.0, 10.0)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCircleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12)],
        ),
        child: Icon(icon, size: 30),
      ),
    );
  }
}

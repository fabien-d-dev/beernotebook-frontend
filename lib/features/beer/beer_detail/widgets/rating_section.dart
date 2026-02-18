import 'package:flutter/material.dart';

class RatingSection extends StatelessWidget {
  final double rating;
  final double initialRating; 
  final ValueChanged<double> onRatingChanged;
  final VoidCallback onSave; 
  final bool isSaving;

  const RatingSection({
    super.key,
    required this.rating,
    required this.initialRating,
    required this.onRatingChanged,
    required this.onSave,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {

    final hasChanged = (rating - initialRating).abs() > 0.01;

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
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
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

        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: hasChanged ? 1.0 : 0.0,
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: hasChanged
                ? ElevatedButton.icon(
                    onPressed: isSaving ? null : onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check),
                    label: const Text("Confirmer la note"),
                  )
                : const SizedBox.shrink(),
          ),
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

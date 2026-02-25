import 'package:flutter/material.dart';

class AppProgressBar extends StatelessWidget {
  final double value; // entre 0.0 et 1.0
  final Color? color;
  final double height;
  final bool showPercentage;

  const AppProgressBar({
    super.key,
    required this.value,
    this.color,
    this.height = 10,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final progressColor =
        color ?? Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pourcentage (optionnel)
        if (showPercentage)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              "${(value * 100).toStringAsFixed(0)} %",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: height,
            backgroundColor: Colors.grey.shade300,
            valueColor:
                AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monbudget/core/constants/app_colors.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed; // null = grisé automatiquement
  final bool isLoading;
  final bool isOutlined; // bouton blanc dordé rouge

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // pleine largeur
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.white : AppColors.primary,
          foregroundColor: isOutlined ? AppColors.primary : Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          side: isOutlined ? const BorderSide(color: AppColors.primary) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}


/*
// Bouton normal
AppButton(
  label: "Se connecter",
  onPressed: () => login(),
)

// Bouton grisé
AppButton(
  label: "Se connecter",
  onPressed: null, // ← grisé automatiquement
)

// Bouton loading
AppButton(
  label: "Se connecter",
  isLoading: true,
)

// Bouton secondaire
AppButton(
  label: "Annuler",
  isOutlined: true,
  onPressed: () => Navigator.pop(context),
)*/
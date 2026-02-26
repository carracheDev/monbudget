import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTextStyles {
  // Montant principal (Dashboard)
  static TextStyle get montantPrincipal => GoogleFonts.montserrat(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  // Titre de page
  static TextStyle get titrePage => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Titre de section
  static TextStyle get titreSection => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  // Montant secondaire
  static TextStyle get montantSecondaire => GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.success,
  );

  // Label secondaire
  static TextStyle get labelSecondaire => GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Corps de texte
  static TextStyle get bodyText => GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
  );
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTextStyles {
  // ================= COULEURS ADAPTATIVES =================

  // Couleur primaire du texte (s'adapte au thème)
  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
  }

  // Couleur secondaire du texte (s'adapte au thème)
  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
  }

  // ================= STYLES DE TEXTE =================

  // Montant principal (Dashboard)
  static TextStyle montantPrincipal(BuildContext context) =>
      GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      );

  // Titre de page
  static TextStyle titrePage(BuildContext context) => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimary(context),
  );

  // Titre de section
  static TextStyle titreSection(BuildContext context) => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary(context),
  );

  // Montant secondaire
  static TextStyle montantSecondaire(BuildContext context) =>
      GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.success,
      );

  // Label secondaire
  static TextStyle labelSecondaire(BuildContext context) => GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: textSecondary(context),
  );

  // Corps de texte
  static TextStyle bodyText(BuildContext context) => GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: textPrimary(context),
  );
}

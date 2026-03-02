import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monbudget/core/constants/app_colors.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'À propos',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App info card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
              ],
            ),
            child: Column(
              children: [
                // App logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),

                // App name
                Text(
                  'MonBudget',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // Version
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Version 1.0.0',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  'Gérez vos finances personnelles facilement avec MonBudget. Suivez vos dépenses, épargnez pour vos objectifs et prenez le contrôle de votre argent.',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Legal documents
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Documents légaux',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                _buildLegalOption(
                  context: context,
                  icon: Icons.description_outlined,
                  title: 'Conditions générales d\'utilisation',
                  subtitle: 'Consultez les CGU',
                  onTap: () => _showCGU(context),
                ),
                const Divider(height: 1),

                _buildLegalOption(
                  context: context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Politique de confidentialité',
                  subtitle: 'Comment nous protégeons vos données',
                  onTap: () => _showPrivacyPolicy(context),
                ),
                const Divider(height: 1),

                _buildLegalOption(
                  context: context,
                  icon: Icons.gavel_outlined,
                  title: 'Mentions légales',
                  subtitle: 'Informations sur l\'éditeur',
                  onTap: () => _showMentionsLegales(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Contact
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Contact',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                _buildLegalOption(
                  context: context,
                  icon: Icons.email_outlined,
                  title: 'Nous contacter',
                  subtitle: 'support@monbudget.com',
                  onTap: () {},
                ),
                const Divider(height: 1),

                _buildLegalOption(
                  context: context,
                  icon: Icons.help_outline,
                  title: 'Aide et FAQ',
                  subtitle: 'Trouvez des réponses à vos questions',
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Copyright
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.favorite, color: AppColors.primary, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Merci d\'utiliser MonBudget',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  '© 2024 MonBudget. Tous droits réservés.',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLegalOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: GoogleFonts.poppins()),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showCGU(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Conditions générales d\'utilisation',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: Text(_cguText, style: GoogleFonts.poppins(fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Politique de confidentialité',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: Text(
                  _privacyText,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMentionsLegales(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Mentions légales',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: Text(
                  _mentionsLegalesText,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const String _cguText = '''
CONDITIONS GÉNÉRALES D'UTILISATION

Dernière mise à jour : Janvier 2024

1. ACCEPTATION DES CONDITIONS
En utilisant l'application MonBudget, vous acceptez d'être lié par les présentes conditions générales d'utilisation. Si vous n'acceptez pas ces conditions, veuillez ne pas utiliser l'application.

2. DESCRIPTION DU SERVICE
MonBudget est une application de gestion de finances personnelles qui vous permet de suivre vos dépenses, gérer vos budgets et épargner pour vos objectifs.

3. UTILISATION DE L'APPLICATION
Vous vous engagez à :
- Utiliser l'application conformément aux présentes conditions
- Ne pas tenter de porter atteinte au fonctionnement de l'application
- Ne pas utiliser l'application à des fins illicites

4. COMPTE UTILISATEUR
Vous êtes responsable de la confidentialité de votre compte et mot de passe. Vous acceptez de signaler immédiatement toute utilisation non autorisée de votre compte.

5. PROPRIÉTÉ INTELLECTUELLE
L'application et tout son contenu sont protégés par les droits de propriété intellectuelle.

6. LIMITATION DE RESPONSABILITÉ
MonBudget est fourni "en l'état". Nous ne garantissons pas que l'application sera toujours disponible ou sans erreur.

7. MODIFICATION DES CONDITIONS
Nous nous réservons le droit de modifier ces conditions à tout moment. Votre utilisation continue de l'application constitue votre acceptation de ces modifications.
''';

  static const String _privacyText = '''
POLITIQUE DE CONFIDENTIALITÉ

Dernière mise à jour : Janvier 2024

1. COLLECTE DES DONNÉES
Nous collectons les informations suivantes :
- Informations de compte (nom, email)
- Données financières (transactions, budgets, épargnes)
- Données d'utilisation de l'application

2. UTILISATION DES DONNÉES
Vos données sont utilisées pour :
- Fournir nos services
- Améliorer l'application
- Communiquer avec vous

3. PROTECTION DES DONNÉES
Nous mettons en œuvre des mesures de sécurité appropriées pour protéger vos données personnelles.

4. VOS DROITS
Vous avez le droit de :
- Accéder à vos données personnelles
- Rectifier vos données
- Supprimer votre compte

5. CONTACT
Pour toute question sur cette politique, contactez-nous à : privacy@monbudget.com
''';

  static const String _mentionsLegalesText = '''
MENTIONS LÉGALES

Dernière mise à jour : Janvier 2024

1. ÉDITEUR
MonBudget est édité par :
MonBudget SAS
Adresse : [Adresse à compléter]
Email : support@monbudget.com

2. DIRECTEUR DE LA PUBLICATION
Le directeur de la publication est [Nom à compléter].

3. HÉBERGEUR
L'application est hébergée par :
[Nom de l'hébergeur à compléter]
[Adresse à compléter]

4. PROPRIÉTÉ INTELLECTUELLE
L'ensemble du contenu de l'application MonBudget est protégé par les droits de propriété intellectuelle.

5. RESPONSABILITÉ
MonBudget s'efforce de fournir des informations exactes mais ne peut garantir l'exactitude complète des informations présentes dans l'application.

6. LIENS EXTERNES
L'application peut contenir des liens vers des sites externes. Nous n'exerçons aucun contrôle sur ces sites.
''';
}

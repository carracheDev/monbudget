import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monbudget/core/constants/app_colors.dart';
import 'package:monbudget/features/auth/auth_provider.dart';
import 'package:monbudget/shared/widgets/app_button.dart';
import 'package:monbudget/shared/widgets/app_input.dart';
import 'package:monbudget/shared/widgets/app_toast.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmePass = TextEditingController();
  bool _acceptCGU = false;
  String? _emailError;
  String? _nomError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmePass.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _nomController.text.isNotEmpty &&
      _emailController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _confirmePass.text.isNotEmpty &&
      _acceptCGU;

  bool _validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  double _getPasswordStrength() {
    final p = _passwordController.text;
    if (p.isEmpty) return 0;
    double strength = 0;
    if (p.length >= 6) strength += 0.25;
    if (p.length >= 10) strength += 0.25;
    if (p.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (p.contains(RegExp(r'[0-9]'))) strength += 0.25;
    return strength;
  }

  Color _getStrengthColor() {
    final s = _getPasswordStrength();
    if (s <= 0.25) return Colors.red;
    if (s <= 0.5) return Colors.orange;
    return Colors.green;
  }

  String _getStrengthLabel() {
    final s = _getPasswordStrength();
    if (s <= 0.25) return 'Faible';
    if (s <= 0.5) return 'Moyen';
    return 'Fort';
  }

  Future<void> _register() async {
    setState(() {
      _emailError = null;
      _nomError = null;
      _passwordError = null;
      _confirmError = null;
    });

    if (_nomController.text.length < 4) {
      setState(() => _nomError = 'Minimum 4 caractères');
      return;
    }
    if (!_validateEmail(_emailController.text)) {
      setState(() => _emailError = 'Email invalide');
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(() => _passwordError = 'Mot de passe trop court');
      return;
    }
    if (_confirmePass.text != _passwordController.text) {
      setState(() => _confirmError = 'Mots de passe non identiques');
      return;
    }

    await ref.read(authProvider.notifier).register(
          nomComplet: _nomController.text,
          email: _emailController.text.trim(),
          motDePasse: _passwordController.text,
        );

    final authState = ref.read(authProvider);
    if (authState.error != null) {
      if (mounted) {
        AppToast.show(context,
            message: authState.error!, type: ToastType.error);
      }
    } else {
      if (mounted) {
        AppToast.show(context,
            message: 'Compte créé ! Connectez-vous.',
            type: ToastType.success);
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final strength = _getPasswordStrength();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Flèche retour
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/login'),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),

              // Titre
              Text(
                'Créer un compte',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),

              // Nom complet
              AppInput(
                label: 'Nom complet',
                hintText: 'Jean Dupont',
                prefixIcon: Icons.person_outline,
                controller: _nomController,
                errorText: _nomError,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // Email
              AppInput(
                label: 'Email',
                hintText: 'exemple@email.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                errorText: _emailError,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // Mot de passe
              AppInput(
                label: 'Mot de passe',
                hintText: '••••••••',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                controller: _passwordController,
                errorText: _passwordError,
                onChanged: (_) => setState(() {}),
              ),

              // Indicateur de force
              if (_passwordController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: strength,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(
                            _getStrengthColor(),
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _getStrengthLabel(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: _getStrengthColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),

              // Confirmation mot de passe
              AppInput(
                label: 'Confirmer le mot de passe',
                hintText: '••••••••',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                controller: _confirmePass,
                errorText: _confirmError,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // CGU
              Row(
                children: [
                  Checkbox(
                    value: _acceptCGU,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _acceptCGU = v!),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        children: [
                          const TextSpan(text: "J'accepte les "),
                          TextSpan(
                            text: "conditions d'utilisation",
                            style: GoogleFonts.poppins(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Bouton S'inscrire
              AppButton(
                label: "S'inscrire",
                onPressed: _isFormValid ? _register : null,
                isLoading: authState.isLoading,
              ),
              const SizedBox(height: 24),

              // Lien Se connecter
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Déjà un compte ? ",
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text(
                        "Se connecter",
                        style: GoogleFonts.poppins(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../theme/app_theme.dart';
import '../widgets/footer_section.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _continueHovered = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final mobile = w < 900;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ─── NavBar ───
          _buildNavBar(mobile),
          // ─── Content ───
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      // THE BACKGROUND IMAGE
                      if (!mobile)
                        Positioned(
                          left: 0,
                          bottom: 0,
                          width: w * 0.45,
                          child: IgnorePointer(
                            child: Image.asset(
                              'assets/images/signup_hero.png',
                              fit: BoxFit.contain,
                              alignment: Alignment.bottomLeft,
                              errorBuilder: (context, error, stackTrace) => const SizedBox(),
                            ),
                          ),
                        ),
                      // THE ACTUAL CONTENT
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: mobile ? 20 : 60,
                          vertical: mobile ? 30 : 50,
                        ),
                        child: mobile
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLeftPanel(mobile),
                                  const SizedBox(height: 40),
                                  _buildFormCard(mobile),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left panel
                                  Expanded(
                                    flex: 5,
                                    child: _buildLeftPanel(mobile),
                                  ),
                                  const SizedBox(width: 50),
                                  // Right panel — form
                                  Expanded(
                                    flex: 6,
                                    child: Center(
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 600),
                                        child: _buildFormCard(mobile),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                ],
                              ),
                      ),
                    ],
                  ),
                  
                  // FOOTER SECTION
                  const FooterSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────── NAVBAR ───────────────────────
  Widget _buildNavBar(bool mobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: mobile ? 20 : 60, vertical: 20),
      child: Row(
        children: [
          // Logo
          GestureDetector(
            onTap: () => Navigator.of(context).pushReplacementNamed('/'),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 40,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [NexaColors.darkNavy, NexaColors.primaryGreen]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text('N', style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))),
                    ),
                  ),
                  const SizedBox(width: 8),
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(text: 'Nexa', style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                      TextSpan(text: 'Ma', style: GoogleFonts.inter(color: NexaColors.primaryGreen, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                    ]),
                  ),
                ],
              ),
            ),
          ),
          if (!mobile) ...[
            const Spacer(),
            ..._buildNavItems(),
            const Spacer(),
            _buildLangSelector(),
            const SizedBox(width: 14),
            _buildLoginBtn(),
            const SizedBox(width: 10),
            _buildSignupBtn(),
          ] else ...[
            const Spacer(),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildNavItems() {
    final items = ['Accueil', 'À propos', 'Fonctionnalités', 'Pour qui ?', 'Ressources'];
    return items.map((label) {
      final hasArrow = label == 'Ressources';
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: NexaColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (hasArrow) ...[
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 16, color: NexaColors.textSecondary),
              ]
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildLangSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(border: Border.all(color: NexaColors.border), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🇲🇦', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text('FR', style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(width: 2),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: NexaColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildLoginBtn() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {}, // Already on login page, or could navigate to self
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: NexaColors.primaryGreen),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Se connecter',
            style: GoogleFonts.inter(
              color: NexaColors.primaryGreen,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignupBtn() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushReplacementNamed('/signup'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: NexaColors.primaryGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "S'inscrire",
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────── LEFT PANEL ───────────────────────
  Widget _buildLeftPanel(bool mobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._buildLeftPanelContent(mobile),
        if (!mobile) const SizedBox(height: 150),
      ],
    );
  }

  List<Widget> _buildLeftPanelContent(bool mobile) {
    return [
      const SizedBox(height: 10),
      // Green badge
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: NexaColors.lightGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, size: 14, color: NexaColors.primaryGreen),
                const SizedBox(width: 6),
                Text(
                  'Plateforme intelligente pour entrepreneurs marocains',
                  style: GoogleFonts.inter(
                    color: NexaColors.darkGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      // Title
      Text(
        'Bienvenue sur NexaMa',
        style: GoogleFonts.inter(
          color: NexaColors.darkNavy,
          fontSize: mobile ? 36 : 48,
          fontWeight: FontWeight.w800,
          height: 1.1,
          letterSpacing: -1,
        ),
      ),
      Text(
        'Connectez-vous à votre\nespace',
        style: GoogleFonts.inter(
          color: NexaColors.primaryGreen,
          fontSize: mobile ? 36 : 48,
          fontWeight: FontWeight.w800,
          height: 1.1,
          letterSpacing: -1,
        ),
      ),
      const SizedBox(height: 24),
      // Description
      Padding(
        padding: const EdgeInsets.only(right: 40),
        child: Text(
          'Accédez à tous vos outils pour gérer, financer, développer et faire croître votre activité.',
          style: GoogleFonts.inter(
            color: NexaColors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.6,
          ),
        ),
      ),
      const SizedBox(height: 48),

      // Bullets
      _buildFeatureBullet(
        icon: Icons.trending_up,
        title: 'Gérez votre entreprise facilement',
        desc: 'Tableaux de bord, finances, factures et plus encore.',
      ),
      const SizedBox(height: 24),
      _buildFeatureBullet(
        icon: Icons.handshake_outlined,
        title: 'Connectez-vous à l\'écosystème',
        desc: 'Entrepreneurs, investisseurs et prestataires réunis.',
      ),
      const SizedBox(height: 24),
      _buildFeatureBullet(
        icon: Icons.school_outlined,
        title: 'Apprenez et progressez',
        desc: 'Formations, ressources et conseils adaptés.',
      ),
      const SizedBox(height: 24),
      _buildFeatureBullet(
        icon: Icons.shield_outlined,
        title: 'Vos données sont sécurisées',
        desc: 'Confidentialité et sécurité au cœur de nos priorités.',
      ),
    ];
  }

  Widget _buildFeatureBullet({required IconData icon, required String title, required String desc}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: NexaColors.lightGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(icon, color: NexaColors.primaryGreen, size: 24),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: NexaColors.darkNavy,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: GoogleFonts.inter(
                  color: NexaColors.textSecondary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────── FORM CARD ───────────────────────
  Widget _buildFormCard(bool mobile) {
    return Container(
      padding: EdgeInsets.all(mobile ? 28 : 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NexaColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title
          Text(
            'Se connecter',
            style: GoogleFonts.inter(
              color: NexaColors.darkNavy,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Entrez vos identifiants pour accéder à votre compte',
            style: GoogleFonts.inter(
              color: NexaColors.textSecondary,
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 32),

          // E-mail ou téléphone
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'E-mail ou téléphone',
              style: GoogleFonts.inter(
                color: NexaColors.darkNavy,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _emailController,
            hint: 'Entrez votre e-mail ou numéro de téléphone',
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 20),

          // Mot de passe
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Mot de passe',
              style: GoogleFonts.inter(
                color: NexaColors.darkNavy,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _passwordController,
            hint: 'Entrez votre mot de passe',
            icon: Icons.lock_outline,
            obscure: _obscurePassword,
            toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          const SizedBox(height: 28),

          // Action Button
          _buildContinueButton(),

          const SizedBox(height: 28),

          // Signup link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Vous n\'avez pas encore de compte ?',
                style: GoogleFonts.inter(
                  color: NexaColors.textSecondary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 6),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pushReplacementNamed('/signup'),
                  child: Text(
                    'S\'inscrire',
                    style: GoogleFonts.inter(
                      color: NexaColors.primaryGreen,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Text Field ───
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    VoidCallback? toggleObscure,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NexaColors.border.withValues(alpha: 0.7)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(
          color: NexaColors.darkNavy,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            color: NexaColors.textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(icon, size: 20, color: NexaColors.textMuted),
          suffixIcon: toggleObscure != null
              ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: NexaColors.textMuted,
                  ),
                  onPressed: toggleObscure,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir votre email et mot de passe')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        ApiConfig.uri('/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'mot_de_passe': _passwordController.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final user = data['user'] as Map<String, dynamic>?;
        final token = data['token'] as String?;
        final role = user?['role']?.toString().toLowerCase();

        if (token != null && user != null) {
          await AuthService.saveAuthData(token, user);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Connexion réussie',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            backgroundColor: NexaColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(20),
          ),
        );

        if (role == 'entrepreneur') {
          Navigator.of(context).pushReplacementNamed(
            '/dashboard/entrepreneur',
            arguments: user,
          );
        } else if (role == 'investisseur') {
          Navigator.of(context).pushReplacementNamed(
            '/dashboard/investisseur',
            arguments: user,
          );
        } else if (role == 'prestataire') {
          Navigator.of(context).pushReplacementNamed(
            '/dashboard/prestataire',
            arguments: user,
          );
        } else if (role == 'formateur') {
          Navigator.of(context).pushReplacementNamed(
            '/dashboard/formateur',
            arguments: user,
          );
        } else if (role == 'administrateur') {
          Navigator.of(context).pushReplacementNamed(
            '/dashboard/admin',
            arguments: user,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Aucun tableau de bord configuré pour le rôle: ${role ?? 'inconnu'}'),
            ),
          );
        }
      } else {
        String errorMessage = 'Erreur lors de la connexion';
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage = data['error']?.toString() ?? errorMessage;
        } catch (_) {
          // Keep default fallback message when body is not JSON.
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de contacter le serveur.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ─── Continue Button ───
  Widget _buildContinueButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _continueHovered = true),
      onExit: (_) => setState(() => _continueHovered = false),
      cursor: _isLoading ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _isLoading ? null : _handleContinue,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: (_continueHovered || _isLoading) ? NexaColors.darkGreen : NexaColors.primaryGreen,
            borderRadius: BorderRadius.circular(12),
            boxShadow: _continueHovered
                ? [BoxShadow(color: NexaColors.primaryGreen.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))]
                : [BoxShadow(color: NexaColors.primaryGreen.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              else ...[
                Text(
                  'Se connecter',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

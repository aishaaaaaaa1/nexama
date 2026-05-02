import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../config/api_config.dart';
import '../theme/app_theme.dart';
import '../widgets/footer_section.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _continueHovered = false;
  bool _backHovered = false;
  bool _isLoading = false;
  bool _isResending = false;
  bool _isCheckingStatus = false;
  int  _resendCooldown = 0;
  Timer? _cooldownTimer;

  int _currentStep = 1;
  String _selectedRole = 'Entrepreneur';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cooldownTimer?.cancel();
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
                          left: 0, // S'aligne parfaitement à gauche de l'écran
                          bottom: 0, // S'aligne en bas de cette section
                          width: w * 0.45, // Prend 45% de l'écran
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
                                    flex: 5, // Un peu plus large pour donner d'espace
                                    child: _buildLeftPanel(mobile),
                                  ),
                                  const SizedBox(width: 50), // Espace au milieu
                                  // Right panel — form
                                  Expanded(
                                    flex: 6, // Reste du formulaire
                                    child: Center(
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 600), // Empêche le form de devenir trop géant sur ultra-large
                                        child: _buildFormCard(mobile),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20), // Padding supplémentaire de sécurité à droite
                                ],
                              ),
                      ),
                    ],
                  ),
                  
                  // FOOTER SECTION ADDED HERE
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
                    errorBuilder: (_, __, ___) => Container(
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
    final items = ['Accueil', 'À propos', 'Fonctionnalités', 'Pour qui ?', 'Tarifs', 'Ressources'];
    return items.map((label) {
      final hasArrow = label == 'Ressources';
      return _NavItem(
        label: label,
        hasArrow: hasArrow,
        onTap: () => Navigator.of(context).pushReplacementNamed('/'),
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
    return _HoverButton(
      text: 'Se connecter',
      textColor: NexaColors.primaryGreen,
      bgColor: Colors.transparent,
      hoverBgColor: NexaColors.lightGreen,
      borderColor: NexaColors.primaryGreen,
      onTap: () => Navigator.of(context).pushReplacementNamed('/login'),
    );
  }

  Widget _buildSignupBtn() {
    return _HoverButton(
      text: "S'inscrire",
      textColor: Colors.white,
      bgColor: NexaColors.primaryGreen,
      hoverBgColor: NexaColors.darkGreen,
      onTap: () {},
    );
  }

  // ─────────────────────── LEFT PANEL ───────────────────────
  Widget _buildLeftPanel(bool mobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._buildLeftPanelContent(mobile),
        if (!mobile) const SizedBox(height: 150), // Padding to ensure scrolling past the hero image if needed
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
          Icon(Icons.groups_outlined, size: 20, color: NexaColors.primaryGreen),
          const SizedBox(width: 8),
          Text(
            'Rejoignez des milliers d\'entrepreneurs marocains',
            style: GoogleFonts.inter(
              color: NexaColors.primaryGreen,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      const SizedBox(height: 30),

      // Title
      Text(
        'Créez votre compte\net donnez vie à',
        style: GoogleFonts.inter(
          color: NexaColors.darkNavy,
          fontSize: mobile ? 32 : 42,
          fontWeight: FontWeight.w800,
          height: 1.15,
          letterSpacing: -1.2,
        ),
      ),
      Text(
        'vos projets',
        style: GoogleFonts.inter(
          color: NexaColors.primaryGreen,
          fontSize: mobile ? 32 : 42,
          fontWeight: FontWeight.w800,
          height: 1.15,
          letterSpacing: -1.2,
        ),
      ),
      const SizedBox(height: 20),

      // Subtitle
      SizedBox(
        width: mobile ? double.infinity : 380,
        child: Text(
          'NexaMa vous accompagne à chaque étape :\nfinancez, gérez, apprenez et développez\nvotre activité en toute simplicité.',
          style: GoogleFonts.inter(
            color: NexaColors.textSecondary,
            fontSize: 14.5,
            height: 1.65,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      const SizedBox(height: 36),

      // Feature bullets (placed on top of the background)
      _buildBullet(Icons.flag_outlined, 'Plateforme 100% marocaine', 'Conforme à la législation et à la fiscalité locale'),
      const SizedBox(height: 18),
      _buildBullet(Icons.apps_outlined, 'Outils tout-en-un', 'Finance, gestion, formation, marketing et plus'),
      const SizedBox(height: 18),
      _buildBullet(Icons.verified_outlined, 'Sécurisé & Fiable', 'Vos données sont protégées et confidentielles'),
      const SizedBox(height: 18),
      _buildBullet(Icons.support_agent_outlined, 'Support local', 'Une équipe à votre écoute'),
    ];
  }

  Widget _buildBullet(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: NexaColors.lightGreen,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: NexaColors.primaryGreen),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                color: NexaColors.primaryGreen,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                color: NexaColors.textSecondary,
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
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
            'S\'inscrire',
            style: GoogleFonts.inter(
              color: NexaColors.darkNavy,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Créez votre compte NexaMa en quelques étapes',
            style: GoogleFonts.inter(
              color: NexaColors.textSecondary,
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 28),

          // Step indicator
          _buildStepIndicator(),
          const SizedBox(height: 32),

          // ─── CONTENT SWITCHER ───
          if (_currentStep == 1) ...[
            // Prénom + Nom
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _firstNameController,
                    hint: 'Prénom',
                    icon: Icons.person_outline,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _lastNameController,
                    hint: 'Nom',
                    icon: Icons.person_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // E-mail
            _buildTextField(
              controller: _emailController,
              hint: 'E-mail',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Téléphone
            _buildPhoneField(),
            const SizedBox(height: 16),

            // Mot de passe
            _buildTextField(
              controller: _passwordController,
              hint: 'Mot de passe',
              icon: Icons.lock_outline,
              obscure: _obscurePassword,
              toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Au moins 8 caractères avec une lettre et un chiffre',
                style: GoogleFonts.inter(
                  color: NexaColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Confirmer mot de passe
            _buildTextField(
              controller: _confirmPasswordController,
              hint: 'Confirmer le mot de passe',
              icon: Icons.lock_outline,
              obscure: _obscureConfirmPassword,
              toggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
          ] else if (_currentStep == 2) ...[
            // Role Selection
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Profil d\'utilisateur',
                style: GoogleFonts.inter(
                  color: NexaColors.darkNavy,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildRoleSelection(),
          ] else if (_currentStep == 3) ...[
            _buildEmailVerificationStep(),
          ] else if (_currentStep == 4) ...[
             Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: NexaColors.lightGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_outline, size: 48, color: NexaColors.primaryGreen),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Compte créé avec succès !',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: NexaColors.darkNavy,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Votre espace ${_selectedRole} est prêt.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: NexaColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 28),

          // Action Buttons — masqués à l'étape 3 (attente de clic email)
          if (_currentStep < 3)
            Row(
              children: [
                if (_currentStep > 1) ...[
                  Expanded(child: _buildBackButton()),
                  const SizedBox(width: 16),
                ],
                Expanded(child: _buildContinueButton()),
              ],
            )
          else if (_currentStep == 4) ...[
            SizedBox(
              width: double.infinity,
              child: _buildContinueButton(label: 'Se connecter'),
            ),
          ],

          if (_currentStep == 1) ...[
            const SizedBox(height: 28),

            // Login link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Vous avez déjà un compte ?',
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
                    onTap: () => Navigator.of(context).pushReplacementNamed('/login'),
                    child: Text(
                      'Se connecter',
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
        ],
      ),
    );
  }

  // ─── Step Indicator ───
  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStep(1, 'Infos', isActive: _currentStep >= 1),
        _buildStepLine(_currentStep >= 2),
        _buildStep(2, 'Profil', isActive: _currentStep >= 2),
        _buildStepLine(_currentStep >= 3),
        _buildStep(3, 'Vérif', isActive: _currentStep >= 3),
        _buildStepLine(_currentStep >= 4),
        _buildStep(4, 'Fin', isActive: _currentStep >= 4),
      ],
    );
  }

  // ─── Role Selection ───
  Widget _buildRoleSelection() {
    return Column(
      children: [
        _buildRoleCard(
          role: 'Entrepreneur',
          description: 'Utilise tous les modules de la plateforme : gestion, financement, formation, projet',
          moduleLabel: 'Tous les modules',
          icon: Icons.rocket_launch_outlined,
        ),
        const SizedBox(height: 12),
        _buildRoleCard(
          role: 'Investisseur',
          description: 'Consulte les projets, évalue les dossiers, contacte les porteurs de projet',
          moduleLabel: 'Module Matching',
          icon: Icons.trending_up_outlined,
        ),
        const SizedBox(height: 12),
        _buildRoleCard(
          role: 'Prestataire',
          description: 'Publie ses services sur la marketplace, gère les commandes et avis clients',
          moduleLabel: 'Marketplace',
          icon: Icons.storefront_outlined,
        ),
        const SizedBox(height: 12),
        _buildRoleCard(
          role: 'Formateur',
          description: 'Crée et publie des micro-formations, suit les apprenants',
          moduleLabel: 'Microlearning',
          icon: Icons.school_outlined,
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required String role,
    required String description,
    required String moduleLabel,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? NexaColors.paleGreen : Colors.white,
            border: Border.all(
              color: isSelected ? NexaColors.primaryGreen : NexaColors.border.withValues(alpha: 0.7),
              width: isSelected ? 1.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Radio btn
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? NexaColors.primaryGreen : NexaColors.textMuted,
                    width: isSelected ? 6 : 1.5,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 18, color: isSelected ? NexaColors.primaryGreen : NexaColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          role,
                          style: GoogleFonts.inter(
                            color: isSelected ? NexaColors.primaryGreen : NexaColors.darkNavy,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? NexaColors.primaryGreen.withValues(alpha: 0.1) : NexaColors.bgLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            moduleLabel,
                            style: GoogleFonts.inter(
                              color: isSelected ? NexaColors.primaryGreen : NexaColors.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: GoogleFonts.inter(
                        color: NexaColors.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
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

  Widget _buildStep(int number, String label, {required bool isActive}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? NexaColors.primaryGreen : Colors.white,
              border: Border.all(
                color: isActive ? NexaColors.primaryGreen : NexaColors.border,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                '$number',
                style: GoogleFonts.inter(
                  color: isActive ? Colors.white : NexaColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              color: isActive ? NexaColors.primaryGreen : NexaColors.textMuted,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(bool completed) {
    return Container(
      width: 60,
      height: 2,
      margin: const EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(
        color: completed ? NexaColors.primaryGreen : NexaColors.border,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  // ─── Text Field ───
  // ─── Step 3 : Email Verification UI ───
  Widget _buildEmailVerificationStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // Animated envelope container
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: NexaColors.lightGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_unread_outlined, size: 52, color: NexaColors.primaryGreen),
          ),
          const SizedBox(height: 24),

          Text(
            'Vérifiez votre boîte mail',
            style: GoogleFonts.inter(
              color: NexaColors.darkNavy,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Show the user's email
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: NexaColors.bgLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: NexaColors.border.withValues(alpha: 0.6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.email_outlined, size: 16, color: NexaColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  _emailController.text.trim(),
                  style: GoogleFonts.inter(
                    color: NexaColors.darkNavy,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Un lien de confirmation a été envoyé à cette adresse.\nCliquez sur le lien dans l\'e-mail pour activer votre compte.',
            style: GoogleFonts.inter(
              color: NexaColors.textSecondary,
              fontSize: 13.5,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // Open Gmail button
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () async {
                final url = Uri.parse('https://mail.google.com/');
                await launchUrl(url, mode: LaunchMode.externalApplication);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: NexaColors.bgLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NexaColors.border.withValues(alpha: 0.7)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.open_in_new, size: 18, color: NexaColors.primaryGreen),
                    const SizedBox(width: 8),
                    Text('Aller sur Gmail',
                        style: GoogleFonts.inter(color: NexaColors.primaryGreen, fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // NEW: Next Button (Check Status)
          MouseRegion(
            cursor: _isCheckingStatus ? SystemMouseCursors.basic : SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _isCheckingStatus ? null : _checkVerificationStatus,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: NexaColors.primaryGreen,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: NexaColors.primaryGreen.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Center(
                  child: _isCheckingStatus 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Continuer', style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Resend button with cooldown
          MouseRegion(
            cursor: _resendCooldown > 0 ? SystemMouseCursors.basic : SystemMouseCursors.click,
            child: GestureDetector(
              onTap: (_isResending || _resendCooldown > 0) ? null : _resendVerificationEmail,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NexaColors.border.withValues(alpha: 0.7)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isResending)
                      const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: NexaColors.primaryGreen))
                    else if (_resendCooldown > 0) ...[ 
                      Icon(Icons.timer_outlined, size: 16, color: NexaColors.textMuted),
                      const SizedBox(width: 8),
                      Text('Renvoyer dans ${_resendCooldown}s',
                          style: GoogleFonts.inter(color: NexaColors.textMuted, fontSize: 13.5, fontWeight: FontWeight.w500)),
                    ] else ...[
                      Icon(Icons.refresh, size: 16, color: NexaColors.primaryGreen),
                      const SizedBox(width: 8),
                      Text("Renvoyer l'email",
                          style: GoogleFonts.inter(color: NexaColors.primaryGreen, fontSize: 13.5, fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
          Text(
            '📌 Pensez à vérifier vos spams si vous ne trouvez pas l\'email.',
            style: GoogleFonts.inter(color: NexaColors.textMuted, fontSize: 12, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Resend Verification Email ───
  Future<void> _resendVerificationEmail() async {
    setState(() => _isResending = true);
    try {
      final response = await http.post(
        ApiConfig.uri('/api/auth/resend-verification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _emailController.text.trim()}),
      );
      if (!mounted) return;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(data['message'] ?? 'Email renvoyé !',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
          backgroundColor: NexaColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(20),
        ));
        // Start 60s cooldown
        setState(() => _resendCooldown = 60);
        _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
          if (!mounted) { t.cancel(); return; }
          setState(() {
            if (_resendCooldown > 0) { _resendCooldown--; } else { t.cancel(); }
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(data['error'] ?? 'Erreur lors du renvoi'),
        ));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de contacter le serveur.')),
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  // ─── Check Verification Status ───
  Future<void> _checkVerificationStatus() async {
    setState(() => _isCheckingStatus = true);
    try {
      final response = await http.get(
        ApiConfig.uri('/api/auth/status?email=${_emailController.text.trim()}'),
      );
      if (!mounted) return;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200 && data['is_verified'] == true) {
        setState(() => _currentStep = 4); // Move to success page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Veuillez d\'abord confirmer votre email en cliquant sur le lien reçu.',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur de connexion au serveur.')),
      );
    } finally {
      if (mounted) setState(() => _isCheckingStatus = false);
    }
  }

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
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  // ─── Phone Field ───
  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NexaColors.border.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          // Phone icon + field
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.inter(
                color: NexaColors.darkNavy,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Téléphone',
                hintStyle: GoogleFonts.inter(
                  color: NexaColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: NexaColors.textMuted),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          // Country code selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: NexaColors.bgLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: NexaColors.border.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🇲🇦', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  '+212',
                  style: GoogleFonts.inter(
                    color: NexaColors.darkNavy,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 16, color: NexaColors.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (_currentStep == 1) {
      if (_firstNameController.text.trim().isEmpty || _lastNameController.text.trim().isEmpty || _emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires')));
        return;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Les mots de passe ne correspondent pas')));
        return;
      }
      setState(() => _currentStep++);
    } else if (_currentStep == 2) {
      // Connect to backend
      setState(() => _isLoading = true);
      try {
        final response = await http.post(
          ApiConfig.uri('/api/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nom_complet': '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
            'email': _emailController.text.trim(),
            'mot_de_passe': _passwordController.text,
            'telephone': _phoneController.text.trim(),
            'role': _selectedRole,
          }),
        );
        
        setState(() => _isLoading = false);

        if (response.statusCode == 201) {
          // Success code 201
          setState(() => _currentStep++);
        } else {
          // Handle error gracefully
          final data = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['error'] ?? 'Erreur lors de l\'inscription', style: GoogleFonts.inter())),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de contacter le serveur, vérifiez votre connexion.')),
        );
      }
    } else if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      // Redirection vers le tableau de bord selon le rôle
      if (_selectedRole == 'Entrepreneur') {
        Navigator.of(context).pushReplacementNamed(
          '/dashboard/entrepreneur',
          arguments: {
            'nom_complet': '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
            'email': _emailController.text.trim(),
            'role': _selectedRole,
          },
        );
      } else if (_selectedRole == 'Investisseur') {
        Navigator.of(context).pushReplacementNamed(
          '/dashboard/investisseur',
          arguments: {
            'nom_complet': '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
            'email': _emailController.text.trim(),
            'role': _selectedRole,
          },
        );
      } else if (_selectedRole == 'Prestataire') {
        Navigator.of(context).pushReplacementNamed(
          '/dashboard/prestataire',
          arguments: {
            'nom_complet': '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
            'email': _emailController.text.trim(),
            'role': _selectedRole,
          },
        );
      } else if (_selectedRole == 'Formateur') {
        Navigator.of(context).pushReplacementNamed(
          '/dashboard/formateur',
          arguments: {
            'nom_complet': '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
            'email': _emailController.text.trim(),
            'role': _selectedRole,
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tableau de bord ${_selectedRole} bientôt disponible !',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
            backgroundColor: NexaColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(20),
          ),
        );
      }
    }
  }

  void _handleBack() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  // ─── Continue Button ───
  Widget _buildContinueButton({String? label}) {
    final bool isHoverActive = _continueHovered || _isLoading;
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
            color: isHoverActive ? NexaColors.darkGreen : NexaColors.primaryGreen,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isHoverActive
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
                  label ?? 'Continuer',
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

  // ─── Back Button ───
  Widget _buildBackButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _backHovered = true),
      onExit: (_) => setState(() => _backHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _handleBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _backHovered ? NexaColors.bgLight : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: NexaColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.arrow_back, size: 18, color: NexaColors.darkNavy),
              const SizedBox(width: 8),
              Text(
                'Retour',
                style: GoogleFonts.inter(
                  color: NexaColors.darkNavy,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}

// ───────────────────── HELPER WIDGETS ─────────────────────

class _NavItem extends StatefulWidget {
  final String label;
  final bool hasArrow;
  final VoidCallback onTap;

  const _NavItem({required this.label, this.hasArrow = false, required this.onTap});

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    style: GoogleFonts.inter(
                      color: _hovered ? NexaColors.primaryGreen : NexaColors.darkNavy,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (widget.hasArrow) ...[
                    const SizedBox(width: 3),
                    Icon(Icons.keyboard_arrow_down, size: 18, color: _hovered ? NexaColors.primaryGreen : NexaColors.textSecondary),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2.5,
                width: _hovered ? 28 : 0,
                decoration: BoxDecoration(color: NexaColors.primaryGreen, borderRadius: BorderRadius.circular(2)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoverButton extends StatefulWidget {
  final String text;
  final Color textColor;
  final Color bgColor;
  final Color hoverBgColor;
  final Color? borderColor;
  final VoidCallback onTap;

  const _HoverButton({
    required this.text,
    required this.textColor,
    required this.bgColor,
    required this.hoverBgColor,
    this.borderColor,
    required this.onTap,
  });

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered ? widget.hoverBgColor : widget.bgColor,
            border: widget.borderColor != null ? Border.all(color: widget.borderColor!) : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            widget.text,
            style: GoogleFonts.inter(color: widget.textColor, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}





import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool _googleHovered = false;
  bool _linkedinHovered = false;

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
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Text(
                  'Un code de vérification a été envoyé à votre e-mail.\nVeuillez vérifier votre boîte de réception.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: NexaColors.textSecondary,
                    fontSize: 14.5,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ] else if (_currentStep == 4) ...[
             Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline, size: 60, color: NexaColors.primaryGreen),
                    const SizedBox(height: 20),
                    Text(
                      'Votre compte a été créé avec succès !',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: NexaColors.darkNavy,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 28),

          // Action Buttons
          if (_currentStep < 4)
            Row(
              children: [
                if (_currentStep > 1) ...[
                  Expanded(child: _buildBackButton()),
                  const SizedBox(width: 16),
                ],
                Expanded(child: _buildContinueButton()),
              ],
            )
          else ...[
            SizedBox(
              width: double.infinity,
              child: _buildContinueButton(label: 'Aller au tableau de bord'),
            ),
          ],

          if (_currentStep == 1) ...[
            const SizedBox(height: 24),
            // Divider
            Row(
              children: [
                Expanded(child: Divider(color: NexaColors.border.withValues(alpha: 0.6))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'ou s\'inscrire avec',
                    style: GoogleFonts.inter(
                      color: NexaColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: NexaColors.border.withValues(alpha: 0.6))),
              ],
            ),
            const SizedBox(height: 20),

            // Social buttons
            Row(
              children: [
                Expanded(child: _buildSocialButton('Google', _googleIcon(), _googleHovered, (v) => setState(() => _googleHovered = v))),
                const SizedBox(width: 16),
                Expanded(child: _buildSocialButton('LinkedIn', _linkedinIcon(), _linkedinHovered, (v) => setState(() => _linkedinHovered = v))),
              ],
            ),
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

  void _handleContinue() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      // Simulate dashboard redirection
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Redirection vers le tableau de bord...',
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          backgroundColor: NexaColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(20),
        ),
      );
    }
  }

  void _handleBack() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  // ─── Continue Button ───
  Widget _buildContinueButton({String? label}) {
    return MouseRegion(
      onEnter: (_) => setState(() => _continueHovered = true),
      onExit: (_) => setState(() => _continueHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _handleContinue,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _continueHovered ? NexaColors.darkGreen : NexaColors.primaryGreen,
            borderRadius: BorderRadius.circular(12),
            boxShadow: _continueHovered
                ? [BoxShadow(color: NexaColors.primaryGreen.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))]
                : [BoxShadow(color: NexaColors.primaryGreen.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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

  // ─── Social Buttons ───
  Widget _buildSocialButton(String label, Widget icon, bool isHovered, ValueChanged<bool> onHover) {
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // TODO: Implement social login
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isHovered ? NexaColors.bgLight : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: NexaColors.border.withValues(alpha: 0.7)),
            boxShadow: isHovered
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: NexaColors.darkNavy,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Google Icon ───
  Widget _googleIcon() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }

  // ─── LinkedIn Icon ───
  Widget _linkedinIcon() {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: const Color(0xFF0A66C2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          'in',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w800,
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

// ─── Google Logo Painter ───
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    // Blue arc (top-right)
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.2
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.65),
      -0.8, -2.0, false, bluePaint,
    );

    // Red arc (top-left)
    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.2
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.65),
      -2.8, -1.0, false, redPaint,
    );

    // Yellow arc (bottom-left)
    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.2
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.65),
      2.35, -1.1, false, yellowPaint,
    );

    // Green arc (bottom-right)
    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.2
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.65),
      1.25, -1.1, false, greenPaint,
    );

    // Blue horizontal bar (right side of G)
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(w * 0.5, h * 0.42, w * 0.45, h * 0.18),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



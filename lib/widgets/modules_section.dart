import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ModulesSection extends StatelessWidget {
  const ModulesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1100;

    return Container(
      width: double.infinity,
      color: NexaColors.bgWhite,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: 70,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Section header
              Text(
                'Tout ce qu\'il vous faut pour réussir',
                style: GoogleFonts.inter(
                  color: NexaColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Une plateforme, ',
                      style: GoogleFonts.inter(
                        color: NexaColors.darkNavy,
                        fontSize: isMobile ? 28 : 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    TextSpan(
                      text: '10 modules essentiels',
                      style: GoogleFonts.inter(
                        color: NexaColors.primaryGreen,
                        fontSize: isMobile ? 28 : 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              // Modules grid
              _buildModulesGrid(isMobile, isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModulesGrid(bool isMobile, bool isTablet) {
    final modules = _getModules();
    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 4);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: isMobile ? 2.5 : 1.15,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        return _ModuleCard(module: modules[index]);
      },
    );
  }

  List<_ModuleData> _getModules() {
    return [
      // Row 1
      _ModuleData(
        icon: Icons.handshake_outlined,
        title: 'Matching\nEntrepreneurs ↔ Investisseurs',
        description: 'Connectez-vous aux bons investisseurs pour concrétiser vos projets.',
      ),
      _ModuleData(
        icon: Icons.dashboard_customize_outlined,
        title: 'Gestion\nAuto-Entrepreneur',
        description: 'Gérez vos finances, factures, déclarations et obligations fiscales facilement.',
      ),
      _ModuleData(
        icon: Icons.storefront_outlined,
        title: 'Marketplace\nde Services B2B',
        description: 'Trouvez des prestataires qualifiés pour développer votre activité.',
      ),
      _ModuleData(
        icon: Icons.auto_awesome_outlined,
        title: 'Business Plan\nGénéré par IA',
        description: 'Créez votre business plan professionnel en quelques minutes.',
      ),
      // Row 2
      _ModuleData(
        icon: Icons.rocket_launch_outlined,
        title: 'Suivi de Projet\nCollaboratif',
        description: 'Collaborez, assignez et suivez vos projets en temps réel.',
      ),
      _ModuleData(
        icon: Icons.school_outlined,
        title: 'Microlearning\npour Entrepreneurs',
        description: 'Formations courtes et pratiques adaptées au marché marocain.',
      ),
      _ModuleData(
        icon: Icons.trending_up_outlined,
        title: 'CRM & Pipeline\nCommercial',
        description: 'Gérez vos prospects, opportunités et clients.',
      ),
      _ModuleData(
        icon: Icons.account_balance_outlined,
        title: 'Comptabilité\n& Finances',
        description: 'Suivi comptable conforme à la réglementation marocaine.',
      ),
      // Row 3
      _ModuleData(
        icon: Icons.groups_outlined,
        title: 'Ressources\nHumaines',
        description: 'Gérez vos employés, contrats et paie facilement.',
      ),
      _ModuleData(
        icon: Icons.inventory_2_outlined,
        title: 'Inventaire\n& Stock',
        description: 'Gestion multi-entrepôts avec mouvements de stock traçables.',
      ),
    ];
  }
}

class _ModuleData {
  final IconData icon;
  final String title;
  final String description;

  const _ModuleData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _ModuleCard extends StatefulWidget {
  final _ModuleData module;

  const _ModuleCard({required this.module});

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -4.0 : 0.0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _isHovered ? Colors.white : NexaColors.bgLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? NexaColors.primaryGreen.withValues(alpha: 0.3)
                : NexaColors.border.withValues(alpha: 0.5),
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: NexaColors.primaryGreen.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon — all green, same style as screenshot
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _isHovered
                    ? NexaColors.primaryGreen.withValues(alpha: 0.12)
                    : NexaColors.paleGreen,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: NexaColors.primaryGreen.withValues(alpha: 0.12),
                ),
              ),
              child: Icon(
                widget.module.icon,
                size: 26,
                color: NexaColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              widget.module.title,
              style: GoogleFonts.inter(
                color: NexaColors.darkNavy,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              widget.module.description,
              style: GoogleFonts.inter(
                color: NexaColors.textSecondary,
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

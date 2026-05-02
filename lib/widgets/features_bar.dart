import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class FeaturesBar extends StatelessWidget {
  const FeaturesBar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    final features = [
      _FeatureItem(Icons.handshake_outlined, 'Financement', 'Connectez-vous avec des investisseurs et financez vos projets.'),
      _FeatureItem(Icons.dashboard_customize_outlined, 'Gestion', 'Gérez votre entreprise facilement avec des outils intelligents.'),
      _FeatureItem(Icons.storefront_outlined, 'Services', 'Trouvez des prestataires qualifiés sur notre marketplace.'),
      _FeatureItem(Icons.school_outlined, 'Formation', 'Développez vos compétences avec des formations adaptées au marché marocain.'),
      _FeatureItem(Icons.folder_outlined, 'Suivi de projet', 'Collaborez et suivez vos projets en temps réel.'),
      _FeatureItem(Icons.verified_outlined, 'Conforme au Maroc', 'Outils 100% adaptés à la législation et fiscalité marocaines.'),
    ];

    return Container(
      width: double.infinity,
      color: NexaColors.bgWhite,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 40,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isMobile
              ? Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: features.map((f) => SizedBox(
                    width: (screenWidth - 32 - 16) / 2 > 300 ? (screenWidth - 32 - 16) / 2 : screenWidth - 32,
                    child: _buildFeatureCard(f),
                  )).toList(),
                )
              : Row(
                  children: features
                      .map((f) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: _buildFeatureCard(f),
                            ),
                          ))
                      .toList(),
                ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(_FeatureItem feature) {
    return _FeatureCardWidget(feature: feature);
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  const _FeatureItem(this.icon, this.title, this.description);
}

class _FeatureCardWidget extends StatefulWidget {
  final _FeatureItem feature;
  const _FeatureCardWidget({required this.feature});

  @override
  State<_FeatureCardWidget> createState() => _FeatureCardWidgetState();
}

class _FeatureCardWidgetState extends State<_FeatureCardWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        decoration: BoxDecoration(
          color: _isHovered ? NexaColors.paleGreen : NexaColors.bgWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isHovered
                ? NexaColors.primaryGreen.withValues(alpha: 0.2)
                : NexaColors.border.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon in circle
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: NexaColors.paleGreen,
                shape: BoxShape.circle,
                border: Border.all(
                  color: NexaColors.primaryGreen.withValues(alpha: 0.15),
                ),
              ),
              child: Icon(
                widget.feature.icon,
                size: 24,
                color: NexaColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 14),
            // Title
            Text(
              widget.feature.title,
              style: GoogleFonts.inter(
                color: NexaColors.darkNavy,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              widget.feature.description,
              style: GoogleFonts.inter(
                color: NexaColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      width: double.infinity,
      color: NexaColors.darkNavy,
      child: Column(
        children: [
          // Main footer content
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 40,
                vertical: 60,
              ),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBrandColumn(),
                        const SizedBox(height: 40),
                        _buildLinksRow(),
                        const SizedBox(height: 40),
                        _buildNewsletterColumn(),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand column
                        Expanded(
                          flex: 3,
                          child: _buildBrandColumn(),
                        ),
                        const SizedBox(width: 40),
                        // Links columns
                        Expanded(
                          flex: 5,
                          child: _buildLinksRow(),
                        ),
                        const SizedBox(width: 40),
                        // Newsletter column
                        Expanded(
                          flex: 3,
                          child: _buildNewsletterColumn(),
                        ),
                      ],
                    ),
            ),
          ),
          // Bottom bar
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 40,
              vertical: 20,
            ),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: isMobile
                    ? Column(
                        children: [
                          _buildCopyrightText(),
                          const SizedBox(height: 10),
                          _buildLegalLinks(),
                          const SizedBox(height: 10),
                          _buildMadeInMorocco(),
                        ],
                      )
                    : Row(
                        children: [
                          _buildCopyrightText(),
                          const Spacer(),
                          _buildLegalLinks(),
                          const Spacer(),
                          _buildMadeInMorocco(),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo image
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 38,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [NexaColors.primaryGreen, Color(0xFF25D366)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Center(
                    child: Text(
                      'N',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Nexa',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text: 'Ma',
                    style: GoogleFonts.inter(
                      color: NexaColors.primaryGreen,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'De l\'idée à la croissance — tout en un.',
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'La plateforme intelligente qui accompagne\nles entrepreneurs marocains dans toutes\nles étapes de leur activité.',
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        // Social icons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _socialIcon('f'),
            const SizedBox(width: 10),
            _socialIcon('𝕏'),
            const SizedBox(width: 10),
            _socialIcon('in'),
            const SizedBox(width: 10),
            _socialIcon('ig'),
            const SizedBox(width: 10),
            _socialIcon('▶'),
          ],
        ),
      ],
    );
  }

  Widget _socialIcon(String label) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: label.length > 1 ? 11 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLinksRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildLinkColumn('Plateforme', [
            'Fonctionnalités',
            'Tarifs',
            'Sécurité',
            'Intégrations',
            'Mises à jour',
          ]),
        ),
        Expanded(
          child: _buildLinkColumn('Ressources', [
            'Blog',
            'Guides',
            'FAQ',
            'Webinaires',
            'Centre d\'aide',
          ]),
        ),
        Expanded(
          child: _buildLinkColumn('À propos', [
            'Qui sommes-nous ?',
            'Notre mission',
            'Carrières',
            'Partenaires',
            'Presse',
          ]),
        ),
      ],
    );
  }

  Widget _buildLinkColumn(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FooterLink(text: link),
            )),
      ],
    );
  }

  Widget _buildNewsletterColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Newsletter',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Recevez nos conseils et nouveautés\nchaque semaine.',
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 18),
        // Email input
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: TextField(
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 13.5,
            ),
            decoration: InputDecoration(
              hintText: 'Votre e-mail',
              hintStyle: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 13.5,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Subscribe button
        _SubscribeButton(),
      ],
    );
  }

  Widget _buildCopyrightText() {
    return Text(
      '© 2026 NexaMa. Tous droits réservés.',
      style: GoogleFonts.inter(
        color: Colors.white.withValues(alpha: 0.4),
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildLegalLinks() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Conditions d\'utilisation',
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '•',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
          ),
        ),
        Text(
          'Politique de confidentialité',
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildMadeInMorocco() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Fabriqué au Maroc ',
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
          ),
        ),
        const Text('🇲🇦', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text(
          ' avec ',
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 12.5,
          ),
        ),
        const Icon(Icons.favorite, size: 14, color: NexaColors.moroccanRed),
      ],
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String text;
  const _FooterLink({required this.text});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: GoogleFonts.inter(
          color: _isHovered
              ? NexaColors.primaryGreen
              : Colors.white.withValues(alpha: 0.55),
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        child: Text(widget.text),
      ),
    );
  }
}

class _SubscribeButton extends StatefulWidget {
  @override
  State<_SubscribeButton> createState() => _SubscribeButtonState();
}

class _SubscribeButtonState extends State<_SubscribeButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: _isHovered ? NexaColors.darkGreen : NexaColors.primaryGreen,
          borderRadius: BorderRadius.circular(10),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: NexaColors.primaryGreen.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            'S\'abonner',
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
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/nav_bar.dart';
import '../widgets/footer_section.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const NavBar(activeIndex: 1), 
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: const [
                  _AboutHeroSection(),
                  FooterSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutHeroSection extends StatelessWidget {
  const _AboutHeroSection();

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isDesktop = sw > 900;

    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        children: [
          // Top section (Text + Image)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 60 : 20,
              vertical: isDesktop ? 80 : 40,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _buildTextContent(),
                        ),
                        const SizedBox(width: 40),
                        Expanded(
                          flex: 6,
                          child: _buildImageContent(),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildTextContent(),
                        const SizedBox(height: 40),
                        _buildImageContent(),
                      ],
                    ),
            ),
          ),
          
          // Bottom section (4 features)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 60 : 20,
              vertical: 40,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildValueCard(Icons.track_changes, 'Notre mission', 'Simplifier l\'entrepreneuriat au Maroc avec des outils performants et accessibles à tous.')),
                        _buildDivider(),
                        Expanded(child: _buildValueCard(Icons.visibility, 'Notre vision', 'Devenir la plateforme n°1 qui propulse les entrepreneurs marocains vers le succès.', iconColor: const Color(0xFF1D4ED8))),
                        _buildDivider(),
                        Expanded(child: _buildValueCard(Icons.diamond_outlined, 'Nos valeurs', 'Innovation, simplicité, écoute, transparence et engagement.')),
                        _buildDivider(),
                        Expanded(child: _buildValueCard(Icons.handshake_outlined, 'Notre engagement', 'Nous sommes à vos côtés à chaque étape de votre parcours entrepreneurial.')),
                      ],
                    )
                  : Column(
                      children: [
                        _buildValueCard(Icons.track_changes, 'Notre mission', 'Simplifier l\'entrepreneuriat au Maroc avec des outils performants et accessibles à tous.'),
                        const SizedBox(height: 20),
                        _buildValueCard(Icons.visibility, 'Notre vision', 'Devenir la plateforme n°1 qui propulse les entrepreneurs marocains vers le succès.', iconColor: const Color(0xFF1D4ED8)),
                        const SizedBox(height: 20),
                        _buildValueCard(Icons.diamond_outlined, 'Nos valeurs', 'Innovation, simplicité, écoute, transparence et engagement.'),
                        const SizedBox(height: 20),
                        _buildValueCard(Icons.handshake_outlined, 'Notre engagement', 'Nous sommes à vos côtés à chaque étape de votre parcours entrepreneurial.'),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 46,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF112D4E),
              height: 1.1,
              letterSpacing: -1,
            ),
            children: const [
              TextSpan(text: 'À propos de '),
              TextSpan(text: 'NexaMa', style: TextStyle(color: Color(0xFF218C53))),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Votre partenaire de confiance pour entreprendre et développer votre activité au Maroc.',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF112D4E),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'NexaMa est une plateforme tout-en-un qui accompagne les entrepreneurs, startups et PME marocaines avec des outils intelligents pour financer, gérer, apprendre et développer leur activité.',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildImageContent() {
    return Image.asset(
      'assets/images/about_illustration.png',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 300,
        color: Colors.grey.shade100,
        child: const Center(child: Text('Image: about_illustration.png')),
      ),
    );
  }

  Widget _buildValueCard(IconData icon, String title, String desc, {Color iconColor = const Color(0xFF218C53)}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 36, color: iconColor),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF112D4E),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                desc,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 80,
      color: Colors.grey.withValues(alpha: 0.2),
      margin: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}

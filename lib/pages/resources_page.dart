import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/nav_bar.dart';
import '../widgets/footer_section.dart';

class ResourcesPage extends StatelessWidget {
  const ResourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const NavBar(activeIndex: 4), // Index 4 -> 'Ressources'
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: const [
                  _ResourcesLayout(),
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

class _ResourcesLayout extends StatelessWidget {
  const _ResourcesLayout();

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isDesktop = sw > 950;
    final isTablet = sw > 600 && sw <= 950;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 60 : 20,
        vertical: 60,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ressources',
              style: GoogleFonts.inter(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF112D4E),
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tout ce qu\'il vous faut pour apprendre,\nvous inspirer et réussir.',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF112D4E).withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 60),
            
            LayoutBuilder(
              builder: (context, constraints) {
                double w;
                if (isDesktop) {
                  w = (constraints.maxWidth - 48) / 3;
                } else if (isTablet) {
                  w = (constraints.maxWidth - 24) / 2;
                } else {
                  w = constraints.maxWidth;
                }

                const double cardHeight = 350;

                return Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: [
                    SizedBox(width: w, height: cardHeight, child: _buildResourceCard('Blog', 'Conseils, actualités et astuces pour entrepreneurs.', 'Voir les articles >', 'assets/images/blog_illu.png')),
                    SizedBox(width: w, height: cardHeight, child: _buildResourceCard('Tutoriels', 'Apprenez à utiliser NexaMa grâce à nos vidéos et guides.', 'Voir les tutoriels >', 'assets/images/tuto_illu.png')),
                    SizedBox(width: w, height: cardHeight, child: _buildResourceCard('Guides pratiques', 'Des guides téléchargeables pour vous accompagner pas à pas.', 'Voir les guides >', 'assets/images/guide_illu.png')),
                    SizedBox(width: w, height: cardHeight, child: _buildResourceCard('FAQ', 'Trouvez rapidement des réponses à vos questions fréquentes.', 'Voir la FAQ >', 'assets/images/faq_illu.png')),
                    SizedBox(width: w, height: cardHeight, child: _buildResourceCard('Support', 'Notre équipe est là pour vous aider à tout moment.', 'Nous contacter >', 'assets/images/support_illu.png')),
                    SizedBox(width: w, height: cardHeight, child: _buildResourceCard('Communauté', 'Rejoignez notre communauté d\'entrepreneurs et échangez vos expériences.', 'Rejoindre >', 'assets/images/community_illu.png')),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceCard(String title, String desc, String linkText, String imagePath) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF112D4E),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              desc,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              linkText,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF218C53),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
               child: Align(
                 alignment: Alignment.bottomCenter,
                 child: Image.asset(
                   imagePath,
                   fit: BoxFit.contain, // Per history instruction to not zoom images
                   errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 50, color: Colors.grey),
                 ),
               ),
            ),
          ],
        ),
      ),
    );
  }
}

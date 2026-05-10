import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/nav_bar.dart';
import '../widgets/footer_section.dart';

class TargetPage extends StatelessWidget {
  const TargetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const NavBar(activeIndex: 3), // Index 3 -> 'Pour qui ?'
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: const [
                  _TargetHeroSection(),
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

class _TargetHeroSection extends StatelessWidget {
  const _TargetHeroSection();

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isDesktop = sw > 900;

    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
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
                    'Pour qui ?',
                    style: GoogleFonts.inter(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF112D4E),
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'NexaMa s\'adapte à tous les profils d\'entrepreneurs.',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF112D4E).withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 60),

                  isDesktop 
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildProfileCard('assets/images/Startups.png', 'Startups', 'Pour structurer votre idée et transformer votre projet en succès.')),
                            const SizedBox(width: 20),
                            Expanded(child: _buildProfileCard('assets/images/pme.png', 'PME', 'Pour gérer efficacement votre entreprise et augmenter votre productivité.')),
                            const SizedBox(width: 20),
                            Expanded(child: _buildProfileCard('assets/images/freelancers.png', 'Freelancers', 'Pour gérer vos clients, vos projets et vos revenus en toute simplicité.')),
                            const SizedBox(width: 20),
                            Expanded(child: _buildProfileCard('assets/images/étudiants entrepreneurs.png', 'Étudiants\nentrepreneurs', 'Pour apprendre, se former et lancer votre premier projet.')),
                            const SizedBox(width: 20),
                            Expanded(child: _buildProfileCard('assets/images/porteur de projets.png', 'Porteurs de projets', 'Pour structurer, financer et concrétiser vos idées avec succès.')),
                          ],
                        )
                      : Column(
                          children: [
                            _buildProfileCard('assets/images/Startups.png', 'Startups', 'Pour structurer votre idée et transformer votre projet en succès.'),
                            const SizedBox(height: 30),
                            _buildProfileCard('assets/images/pme.png', 'PME', 'Pour gérer efficacement votre entreprise et augmenter votre productivité.'),
                            const SizedBox(height: 30),
                            _buildProfileCard('assets/images/freelancers.png', 'Freelancers', 'Pour gérer vos clients, vos projets et vos revenus en toute simplicité.'),
                            const SizedBox(height: 30),
                            _buildProfileCard('assets/images/étudiants entrepreneurs.png', 'Étudiants\nentrepreneurs', 'Pour apprendre, se former et lancer votre premier projet.'),
                            const SizedBox(height: 30),
                            _buildProfileCard('assets/images/porteur de projets.png', 'Porteurs de projets', 'Pour structurer, financer et concrétiser vos idées avec succès.'),
                          ],
                        ),
                ],
              ),
            ),
          ),
          
          // Bottom Skyline Background
          SizedBox(
            width: double.infinity,
            height: 180,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        Color(0xFFE8F2ED),
                      ],
                    ),
                  ),
                ),
                Image.asset(
                  'assets/images/skyline_bg.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(); 
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(String imagePath, String title, String desc) {
    return Column(
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA), // Light background to frame the image nicely
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain, // As requested in history to avoid zoom/crop
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF112D4E),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          desc,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

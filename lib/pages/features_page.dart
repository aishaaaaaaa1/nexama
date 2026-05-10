import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/nav_bar.dart';
import '../widgets/footer_section.dart';

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const NavBar(activeIndex: 2), // Index 2 -> 'Fonctionnalités'
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: const [
                  _FeaturesHeroSection(),
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

class _FeaturesHeroSection extends StatelessWidget {
  const _FeaturesHeroSection();

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isDesktop = sw > 900;

    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 60 : 20,
              vertical: isDesktop ? 60 : 40,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fonctionnalités',
                    style: GoogleFonts.inter(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF112D4E),
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tous les outils dont vous avez besoin,\nréunis en une seule plateforme.',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4B5563),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 50),
                  
                  isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left grid
                            Expanded(
                              flex: 5,
                              child: _buildGrid(),
                            ),
                            const SizedBox(width: 50),
                            // Right image
                            Expanded(
                              flex: 6,
                              child: _buildImage(),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildGrid(),
                            const SizedBox(height: 40),
                            _buildImage(),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double w = (constraints.maxWidth - 20) / 2;
        if (w < 230) w = constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(width: w, child: _buildFeatureCard(Icons.assignment, Colors.blue.shade600, 'Gestion de projet', 'Planifiez, organisez et suivez vos projets\nen toute simplicité.')),
            SizedBox(width: w, child: _buildFeatureCard(Icons.account_balance_wallet, Colors.green.shade600, 'Finance & Comptabilité', 'Suivez vos revenus, dépenses,\nfactures et prévisions financières.')),
            SizedBox(width: w, child: _buildFeatureCard(Icons.people, Colors.blue.shade700, 'CRM & Clients', 'Gérez vos contacts, suivez\nvos ventes et fidélisez vos clients.')),
            SizedBox(width: w, child: _buildFeatureCard(Icons.menu_book, Colors.orange.shade500, 'Microlearning', 'Apprenez à votre rythme\navec des formations courtes et pratiques.')),
            SizedBox(width: w, child: _buildFeatureCard(Icons.inventory_2, Colors.blueGrey.shade600, 'Gestion de stock', 'Suivez vos produits,\ninventaires et mouvements de stock.')),
            SizedBox(width: w, child: _buildFeatureCard(Icons.bar_chart, Colors.purple.shade500, 'Analyse & Rapports', 'Des tableaux de bord et\nstatistiques pour piloter votre croissance.')),
            
            // Full width item
            SizedBox(
              width: constraints.maxWidth,
              child: _buildFeatureCard(
                Icons.handshake, 
                Colors.indigo.shade500, 
                'Services & Accompagnement', 
                'Accédez à des experts, financements et opportunités pour accélérer votre développement.'
              )
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeatureCard(IconData icon, Color iconColor, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    color: const Color(0xFF112D4E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: const Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Center(
      child: Image.asset(
        'assets/images/dashboard_mockup.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 350,
          color: Colors.grey.shade100,
          child: const Center(child: Text('Image introuvable: dashboard_mockup.png')),
        ),
      ),
    );
  }
}

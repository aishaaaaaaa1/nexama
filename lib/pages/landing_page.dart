import 'package:flutter/material.dart';
import '../widgets/nav_bar.dart';
import '../widgets/hero_section.dart';
import '../widgets/features_bar.dart';
import '../widgets/modules_section.dart';
import '../widgets/stats_section.dart';
import '../widgets/testimonials_section.dart';
import '../widgets/cta_section.dart';
import '../widgets/footer_section.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const NavBar(), // NavBar fixe en haut
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: const [
                  HeroSection(),
                  FeaturesBar(),
                  StatsSection(),
                  ModulesSection(),
                  TestimonialsSection(),
                  CtaSection(),
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

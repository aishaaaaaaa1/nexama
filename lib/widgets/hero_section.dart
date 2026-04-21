import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> with SingleTickerProviderStateMixin {
  bool _ctaHovered = false;
  bool _videoHovered = false;
  late AnimationController _anim;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(duration: const Duration(milliseconds: 900), vsync: this);
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final mobile = w < 900;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 20 : 60,
        vertical: mobile ? 40 : 80,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: mobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeTransition(opacity: _fade, child: _leftCol(mobile)),
                    const SizedBox(height: 50),
                    _rightCol(mobile),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: FadeTransition(opacity: _fade, child: _leftCol(mobile))),
                    const SizedBox(width: 40),
                    Expanded(child: _rightCol(mobile)),
                  ],
                ),
        ),
      ),
    );
  }

  // ────────────── LEFT COLUMN ──────────────
  Widget _leftCol(bool mobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: NexaColors.lightGreen,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: NexaColors.primaryGreen.withValues(alpha: 0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(color: NexaColors.primaryGreen, shape: BoxShape.circle),
                child: const Icon(Icons.shield_outlined, size: 13, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'La plateforme tout-en-un pour entrepreneurs marocains',
                  style: GoogleFonts.inter(color: NexaColors.primaryGreen, fontSize: 13, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // Title
        Text(
          'De l\'idée à la croissance,',
          style: GoogleFonts.inter(
            color: NexaColors.darkNavy,
            fontSize: mobile ? 36 : 52,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -1.5,
          ),
        ),
        Text(
          'tout en un.',
          style: GoogleFonts.inter(
            color: NexaColors.primaryGreen,
            fontSize: mobile ? 36 : 52,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: 24),

        // Description
        SizedBox(
          width: mobile ? double.infinity : 480,
          child: Text(
            'NexaMa accompagne les entrepreneurs, startups et PME marocaines avec des outils intelligents pour financer, gérer, apprendre et développer leur activité.',
            style: GoogleFonts.inter(color: NexaColors.textSecondary, fontSize: 16.5, height: 1.7),
          ),
        ),
        const SizedBox(height: 36),

        // Buttons
        Wrap(
          spacing: 16,
          runSpacing: 14,
          children: [
            // Primary CTA
            MouseRegion(
              onEnter: (_) => setState(() => _ctaHovered = true),
              onExit: (_) => setState(() => _ctaHovered = false),
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                decoration: BoxDecoration(
                  color: _ctaHovered ? NexaColors.darkGreen : NexaColors.primaryGreen,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: NexaColors.primaryGreen.withValues(alpha: _ctaHovered ? 0.45 : 0.25),
                      blurRadius: _ctaHovered ? 24 : 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Commencer gratuitement', style: GoogleFonts.inter(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                  ],
                ),
              ),
            ),
            // Video CTA
            MouseRegion(
              onEnter: (_) => setState(() => _videoHovered = true),
              onExit: (_) => setState(() => _videoHovered = false),
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                decoration: BoxDecoration(
                  color: _videoHovered ? NexaColors.bgLight : Colors.transparent,
                  border: Border.all(color: NexaColors.border),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: NexaColors.darkNavy, width: 1.5)),
                      child: const Icon(Icons.play_arrow_rounded, size: 18, color: NexaColors.darkNavy),
                    ),
                    const SizedBox(width: 10),
                    Text('Voir la vidéo', style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 15.5, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),

        // Trust line
        Row(
          children: [
            const Icon(Icons.verified_user_outlined, size: 16, color: NexaColors.primaryGreen),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Inscription gratuite  •  Aucune carte bancaire requise',
                style: GoogleFonts.inter(color: NexaColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ────────────── RIGHT COLUMN — Just the image ──────────────
  Widget _rightCol(bool mobile) {
    return FadeTransition(
      opacity: _fade,
      child: Transform.scale(
        scale: 1.15, // Augmente la taille de l'image
        child: Image.asset(
          'assets/images/dashboard_mockup.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback placeholder if image not yet placed
            return Container(
              height: mobile ? 300 : 480,
              decoration: BoxDecoration(
                color: NexaColors.lightGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.image_outlined, size: 60, color: NexaColors.primaryGreen.withValues(alpha: 0.4)),
                    const SizedBox(height: 12),
                    Text(
                      'Placez dashboard_mockup.png\ndans assets/images/',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: NexaColors.primaryGreen.withValues(alpha: 0.6), fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

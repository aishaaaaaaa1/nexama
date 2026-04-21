import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

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
                'Ils nous font',
                style: GoogleFonts.inter(
                  color: NexaColors.darkNavy,
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'confiance',
                style: GoogleFonts.inter(
                  color: NexaColors.primaryGreen,
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              // Testimonial cards
              isMobile
                  ? Column(
                      children: _getTestimonials()
                          .map((t) => Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: _TestimonialCard(testimonial: t),
                              ))
                          .toList(),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _getTestimonials()
                          .map((t) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: _TestimonialCard(testimonial: t),
                                ),
                              ))
                          .toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  List<_Testimonial> _getTestimonials() {
    return [
      _Testimonial(
        name: 'Youssef El Amrani',
        role: 'Fondateur de GreenBay',
        quote:
            'NexaMa m\'a permis de trouver un investisseur en moins de 2 mois. La plateforme est simple, complète et adaptée à la réalité marocaine.',
        rating: 5,
        avatarColor: const Color(0xFF198754),
        initials: 'YE',
      ),
      _Testimonial(
        name: 'Salma Benjeloun',
        role: 'Gérante d\'une agence digitale',
        quote:
            'Grâce à NexaMa, je gère toute mon entreprise au même endroit : factures, comptabilité, projets, formation... un vrai gain de temps !',
        rating: 5,
        avatarColor: const Color(0xFF6F42C1),
        initials: 'SB',
      ),
      _Testimonial(
        name: 'Mehdi Ait Lahcen',
        role: 'Développeur Web',
        quote:
            'La marketplace m\'a permis de trouver des clients et de développer mon activité plus rapidement.',
        rating: 5,
        avatarColor: const Color(0xFF0D6EFD),
        initials: 'ML',
      ),
    ];
  }
}

class _Testimonial {
  final String name;
  final String role;
  final String quote;
  final int rating;
  final Color avatarColor;
  final String initials;

  const _Testimonial({
    required this.name,
    required this.role,
    required this.quote,
    required this.rating,
    required this.avatarColor,
    required this.initials,
  });
}

class _TestimonialCard extends StatefulWidget {
  final _Testimonial testimonial;

  const _TestimonialCard({required this.testimonial});

  @override
  State<_TestimonialCard> createState() => _TestimonialCardState();
}

class _TestimonialCardState extends State<_TestimonialCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -4.0 : 0.0),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _isHovered ? Colors.white : NexaColors.bgLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? NexaColors.primaryGreen.withValues(alpha: 0.2)
                : NexaColors.border.withValues(alpha: 0.5),
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: NexaColors.primaryGreen.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stars
            Row(
              children: List.generate(
                widget.testimonial.rating,
                (index) => const Padding(
                  padding: EdgeInsets.only(right: 3),
                  child: Icon(Icons.star_rounded, size: 20, color: NexaColors.starGold),
                ),
              ),
            ),
            const SizedBox(height: 18),
            // Quote
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '❝',
                  style: GoogleFonts.inter(
                    color: NexaColors.primaryGreen,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 0.8,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.testimonial.quote,
                    style: GoogleFonts.inter(
                      color: NexaColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.65,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Divider
            Container(
              height: 1,
              color: NexaColors.border.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 18),
            // Author
            Row(
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: widget.testimonial.avatarColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      widget.testimonial.initials,
                      style: GoogleFonts.inter(
                        color: widget.testimonial.avatarColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.testimonial.name,
                      style: GoogleFonts.inter(
                        color: NexaColors.darkNavy,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.testimonial.role,
                      style: GoogleFonts.inter(
                        color: NexaColors.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

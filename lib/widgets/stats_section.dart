import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class StatsSection extends StatefulWidget {
  const StatsSection({super.key});

  @override
  State<StatsSection> createState() => _StatsSectionState();
}

class _StatsSectionState extends State<StatsSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

  final List<_StatItem> _stats = [
    _StatItem(
      icon: Icons.groups_outlined,
      value: '5 000+',
      label: 'Entrepreneurs rejoints',
    ),
    _StatItem(
      icon: Icons.assignment_outlined,
      value: '800+',
      label: 'Projets accompagnés',
    ),
    _StatItem(
      icon: Icons.account_balance_wallet_outlined,
      value: '5 M MAD+',
      label: 'Levés via la plateforme',
    ),
    _StatItem(
      icon: Icons.school_outlined,
      value: '15 000+',
      label: 'Formations complétées',
    ),
    _StatItem(
      icon: Icons.star_outline,
      value: '300+',
      label: 'Prestataires référencés',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: NexaColors.bgLight,
        border: Border(
          top: BorderSide(color: NexaColors.border.withValues(alpha: 0.4)),
          bottom: BorderSide(color: NexaColors.border.withValues(alpha: 0.4)),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 40,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: FadeTransition(
            opacity: _animation,
            child: isMobile
                ? Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 24,
                    runSpacing: 24,
                    children: _stats
                        .map((s) => _buildStatItem(s))
                        .toList(),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _stats.asMap().entries.map((entry) {
                      final index = entry.key;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStatItem(entry.value),
                          if (index < _stats.length - 1)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              width: 1,
                              height: 50,
                              color: NexaColors.border.withValues(alpha: 0.4),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(_StatItem stat) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Green outlined icon in circle
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: NexaColors.paleGreen,
            shape: BoxShape.circle,
            border: Border.all(
              color: NexaColors.primaryGreen.withValues(alpha: 0.15),
            ),
          ),
          child: Icon(
            stat.icon,
            size: 22,
            color: NexaColors.primaryGreen,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Value — all in green
            Text(
              stat.value,
              style: GoogleFonts.inter(
                color: NexaColors.primaryGreen,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            // Label — gray
            Text(
              stat.label,
              style: GoogleFonts.inter(
                color: NexaColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatItem {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });
}

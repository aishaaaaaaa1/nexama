import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _hoveredIndex = -1;
  bool _loginHovered = false;
  bool _signupHovered = false;

  final _menu = ['Accueil', 'À propos', 'Fonctionnalités', 'Pour qui ?', 'Ressources'];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final mobile = w < 1200; // Increased from 900 to prevent horizontal overflow

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: mobile ? 20 : 60, vertical: 30),
      child: Row(
        children: [
          _logo(),
          if (!mobile) ...[
            const Spacer(),
            for (var i = 0; i < _menu.length; i++) _navItem(_menu[i], i),
            const Spacer(),
            _langSelector(),
            const SizedBox(width: 14),
            _loginBtn(),
            const SizedBox(width: 10),
            _signupBtn(),
          ] else ...[
            const Spacer(),
            IconButton(icon: const Icon(Icons.menu, color: NexaColors.darkNavy), onPressed: () {}),
          ],
        ],
      ),
    );
  }

  Widget _logo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo image
        Image.asset(
          'assets/images/logo.png',
          height: 40,
          errorBuilder: (_, __, ___) => Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [NexaColors.darkNavy, NexaColors.primaryGreen]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text('N', style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))),
          ),
        ),
        const SizedBox(width: 8),
        RichText(
          text: TextSpan(children: [
            TextSpan(text: 'Nexa', style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            TextSpan(text: 'Ma', style: GoogleFonts.inter(color: NexaColors.primaryGreen, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          ]),
        ),
      ],
    );
  }

  Widget _navItem(String label, int i) {
    final active = i == 0;
    final hovered = _hoveredIndex == i;
    final hasArrow = label == 'Ressources';

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = i),
      onExit: (_) => setState(() => _hoveredIndex = -1),
      cursor: SystemMouseCursors.click,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: active || hovered ? NexaColors.primaryGreen : NexaColors.darkNavy,
                    fontSize: 14.5,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                if (hasArrow) ...[
                  const SizedBox(width: 3),
                  Icon(Icons.keyboard_arrow_down, size: 18, color: hovered ? NexaColors.primaryGreen : NexaColors.textSecondary),
                ],
              ],
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2.5,
              width: active || hovered ? 28 : 0,
              decoration: BoxDecoration(color: NexaColors.primaryGreen, borderRadius: BorderRadius.circular(2)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _langSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(border: Border.all(color: NexaColors.border), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Moroccan flag emoji
          const Text('🇲🇦', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text('FR', style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(width: 2),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: NexaColors.textSecondary),
        ],
      ),
    );
  }

  Widget _loginBtn() {
    return MouseRegion(
      onEnter: (_) => setState(() => _loginHovered = true),
      onExit: (_) => setState(() => _loginHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed('/login'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: _loginHovered ? NexaColors.lightGreen : Colors.transparent,
            border: Border.all(color: NexaColors.primaryGreen),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('Se connecter', style: GoogleFonts.inter(color: NexaColors.primaryGreen, fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _signupBtn() {
    return MouseRegion(
      onEnter: (_) => setState(() => _signupHovered = true),
      onExit: (_) => setState(() => _signupHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed('/signup'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          decoration: BoxDecoration(
            color: _signupHovered ? NexaColors.darkGreen : NexaColors.primaryGreen,
            borderRadius: BorderRadius.circular(10),
            boxShadow: _signupHovered
                ? [BoxShadow(color: NexaColors.primaryGreen.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))]
                : [],
          ),
          child: Text("S'inscrire", style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

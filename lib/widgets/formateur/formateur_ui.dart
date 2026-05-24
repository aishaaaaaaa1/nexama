import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

/// Couleurs dédiées espace formateur (violet + vert Nexa).
class FormateurColors {
  FormateurColors._();
  static const Color accent = Color(0xFF8B5CF6);
  static const Color accentLight = Color(0xFFF5F3FF);
  static const Color muted = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color surface = Color(0xFFF8FAFC);
}

class FormateurStatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? hint;

  const FormateurStatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.hint,
  });
}

/// En-tête standard : titre, sous-titre, recherche optionnelle, action.
class FormateurPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? below;

  const FormateurPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.below,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(subtitle!, style: GoogleFonts.inter(fontSize: 13, color: FormateurColors.muted, height: 1.4)),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
        if (below != null) ...[const SizedBox(height: 16), below!],
      ],
    );
  }
}

class FormateurSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final double width;

  const FormateurSearchField({
    super.key,
    this.controller,
    this.hint = 'Rechercher...',
    this.onChanged,
    this.width = 240,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 40,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.inter(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
          prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: FormateurColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: FormateurColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: FormateurColors.accent, width: 1.5)),
        ),
      ),
    );
  }
}

class FormateurStatsRow extends StatelessWidget {
  final List<FormateurStatItem> items;

  const FormateurStatsRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 14),
          Expanded(child: _StatTile(item: items[i])),
        ],
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final FormateurStatItem item;
  const _StatTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FormateurColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: item.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(item.icon, color: item.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: FormateurColors.muted)),
                const SizedBox(height: 4),
                Text(item.value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
                if (item.hint != null)
                  Text(item.hint!, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FormateurEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const FormateurEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FormateurColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: const Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13, color: FormateurColors.muted, height: 1.45)),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add, size: 18),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(backgroundColor: FormateurColors.accent, foregroundColor: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FormateurLoading extends StatelessWidget {
  const FormateurLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(color: FormateurColors.accent));
  }
}

class FormateurSectionCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const FormateurSectionCard({
    super.key,
    this.title,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: FormateurColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
            const SizedBox(height: 20),
          ],
          child,
        ],
      ),
    );
  }
}

class FormateurChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const FormateurChip({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? FormateurColors.accentLight : FormateurColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? FormateurColors.accent : FormateurColors.border),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? FormateurColors.accent : FormateurColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}

/// Format entier MAD avec espaces (ex. 8 450).
String formatMad(num value) {
  final n = value.toInt().abs();
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return buf.toString();
}

enum FormateurListViewMode { table, cards }

class FormateurViewToggle extends StatelessWidget {
  final FormateurListViewMode mode;
  final ValueChanged<FormateurListViewMode> onChanged;

  const FormateurViewToggle({super.key, required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FormateurColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: FormateurColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.view_list_rounded, FormateurListViewMode.table, 'Tableau'),
          _btn(Icons.view_module_rounded, FormateurListViewMode.cards, 'Cartes'),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, FormateurListViewMode m, String tooltip) {
    final selected = mode == m;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => onChanged(m),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: selected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4)] : null,
          ),
          child: Icon(icon, size: 20, color: selected ? FormateurColors.accent : FormateurColors.muted),
        ),
      ),
    );
  }
}

ButtonStyle formateurPrimaryStyle() => ElevatedButton.styleFrom(
      backgroundColor: FormateurColors.accent,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );

ButtonStyle formateurGreenStyle() => ElevatedButton.styleFrom(
      backgroundColor: NexaColors.primaryGreen,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';

/// Page **Configuration** NexaMa (SaaS e-learning) — remplace l’ancienne page paramètres.
/// Le nom de classe [ParametresPage] est conservé pour les imports dashboard existants.
class ParametresPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const ParametresPage({super.key, this.userData});

  @override
  State<ParametresPage> createState() => _ParametresPageState();
}

class _NavItem {
  const _NavItem({required this.id, required this.icon, required this.label});
  final int id;
  final IconData icon;
  final String label;
}

class _ParametresPageState extends State<ParametresPage> with SingleTickerProviderStateMixin {
  static const _violet = Color(0xFF7C3AED);
  static const _violetSoft = Color(0xFFEDE9FE);
  static const _surface = Color(0xFFF8FAFC);
  static const _border = Color(0xFFE8ECF2);
  static const _muted = Color(0xFF64748B);

  static const _nav = <_NavItem>[
    _NavItem(id: 0, icon: Icons.tune_rounded, label: 'Général'),
    _NavItem(id: 1, icon: Icons.palette_outlined, label: 'Apparence'),
    _NavItem(id: 2, icon: Icons.shield_outlined, label: 'Sécurité'),
    _NavItem(id: 3, icon: Icons.notifications_outlined, label: 'Notifications'),
    _NavItem(id: 4, icon: Icons.group_outlined, label: 'Utilisateurs'),
    _NavItem(id: 5, icon: Icons.payments_outlined, label: 'Paiements'),
    _NavItem(id: 6, icon: Icons.extension_outlined, label: 'Intégrations'),
    _NavItem(id: 7, icon: Icons.school_outlined, label: 'Apprentissage'),
    _NavItem(id: 8, icon: Icons.cloud_outlined, label: 'Données & Sauvegarde'),
  ];

  int _section = 0;
  late AnimationController _anim;

  late TextEditingController _cPlatform;
  late TextEditingController _cEmail;
  late TextEditingController _cUrl;
  late TextEditingController _cApiKey;
  late TextEditingController _cThemePersonalize;

  String _langue = 'Français (FR)';
  String _fuseau = 'Africa/Casablanca';
  String _devise = 'MAD';
  String _couleurTheme = 'Violet NexaMa';

  bool _darkMode = false;
  String _tailleUi = 'Confort';

  bool _notifEmail = true;
  bool _notifPush = true;
  bool _alertQuiz = true;
  bool _alertEtudiants = true;
  bool _comMarketing = false;

  bool _a2f = false;
  bool _certifAuto = true;
  bool _quizAuto = false;
  bool _conditionsReussite = true;
  bool _sauvegardeAuto = true;

  bool _intMeet = true;
  bool _intZoom = false;
  bool _intStripe = true;
  bool _intPaypal = false;

  int _scoreMinimal = 60;
  final double _progressDemo = 0.72;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 420))..forward();
    _cPlatform = TextEditingController(text: 'NexaMa');
    _cEmail = TextEditingController(text: 'contact@nexama.ma');
    _cUrl = TextEditingController(text: 'app.nexama.ma');
    _cApiKey = TextEditingController(text: 'nx_live_••••••••••••');
    _cThemePersonalize = TextEditingController(text: 'Accent violet, cartes arrondies, typographie Inter.');
  }

  @override
  void dispose() {
    _anim.dispose();
    _cPlatform.dispose();
    _cEmail.dispose();
    _cUrl.dispose();
    _cApiKey.dispose();
    _cThemePersonalize.dispose();
    super.dispose();
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m, style: GoogleFonts.inter(fontWeight: FontWeight.w500)), behavior: SnackBarBehavior.floating, margin: const EdgeInsets.fromLTRB(16, 0, 16, 24)),
    );
  }

  void _save() => _toast('Modifications enregistrées (démo).');

  void _reset() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Réinitialiser ?', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: Text('Les valeurs affichées seront remises aux réglages par défaut de la démo.', style: GoogleFonts.inter(color: _muted, height: 1.45)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Annuler', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _cPlatform.text = 'NexaMa';
                _cEmail.text = 'contact@nexama.ma';
                _cUrl.text = 'app.nexama.ma';
                _darkMode = false;
                _a2f = false;
                _notifEmail = _notifPush = _alertQuiz = _alertEtudiants = true;
                _comMarketing = false;
                _certifAuto = true;
                _quizAuto = false;
                _conditionsReussite = true;
                _cThemePersonalize.text = 'Accent violet, cartes arrondies, typographie Inter.';
                _sauvegardeAuto = true;
                _scoreMinimal = 60;
                _intMeet = true;
                _intZoom = false;
                _intStripe = true;
                _intPaypal = false;
                _section = 0;
              });
              _toast('Réinitialisation effectuée.');
            },
            style: FilledButton.styleFrom(backgroundColor: _violet),
            child: Text('Réinitialiser', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic),
      child: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth >= 960;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(wide),
              const SizedBox(height: 20),
              Expanded(
                child: wide ? Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [_sidebar(wide), const SizedBox(width: 20), Expanded(child: _contentCard())]) : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [_sidebar(wide), const SizedBox(height: 14), Expanded(child: _contentCard())]),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _header(bool wide) {
    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: _reset,
          icon: const Icon(Icons.restart_alt_rounded, size: 20),
          label: Text('Réinitialiser', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(foregroundColor: NexaColors.darkNavy, side: const BorderSide(color: _border), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        ),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_outlined, size: 20),
          label: Text('Sauvegarder les modifications', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          style: FilledButton.styleFrom(backgroundColor: _violet, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
        ),
      ],
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.all(wide ? 26 : 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.white.withValues(alpha: 0.92), _violetSoft.withValues(alpha: 0.55)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.65)),
            boxShadow: [BoxShadow(color: _violet.withValues(alpha: 0.08), blurRadius: 32, offset: const Offset(0, 12))],
          ),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Configuration', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: NexaColors.darkNavy, letterSpacing: -0.6)),
                          const SizedBox(height: 8),
                          Text('Pilotez l’identité, la sécurité, les notifications et l’expérience d’apprentissage de votre plateforme NexaMa.', style: GoogleFonts.inter(fontSize: 14.5, color: _muted, height: 1.45, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    actions,
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Configuration', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: NexaColors.darkNavy)),
                    const SizedBox(height: 8),
                    Text('Paramètres plateforme, sécurité et e-learning.', style: GoogleFonts.inter(fontSize: 13.5, color: _muted, height: 1.4)),
                    const SizedBox(height: 16),
                    actions,
                  ],
                ),
        ),
      ),
    );
  }

  Widget _sidebar(bool wide) {
    final nav = ListView.separated(
      shrinkWrap: !wide,
      physics: wide ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
      itemCount: _nav.length,
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemBuilder: (context, i) {
        final e = _nav[i];
        final sel = _section == e.id;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _section = e.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: sel ? LinearGradient(colors: [_violet, _violet.withValues(alpha: 0.85)], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
                color: sel ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: sel ? Colors.transparent : _border.withValues(alpha: 0.6)),
                boxShadow: sel ? [BoxShadow(color: _violet.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))] : null,
              ),
              child: Row(
                children: [
                  Icon(e.icon, size: 20, color: sel ? Colors.white : _muted),
                  const SizedBox(width: 12),
                  Expanded(child: Text(e.label, style: GoogleFonts.inter(fontWeight: sel ? FontWeight.w700 : FontWeight.w600, fontSize: 13.5, color: sel ? Colors.white : NexaColors.darkNavy))),
                ],
              ),
            ),
          ),
        );
      },
    );

    final shell = Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Padding(padding: const EdgeInsets.all(12), child: nav),
    );

    if (wide) return SizedBox(width: 248, child: shell);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: _nav.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final e = _nav[i];
          final sel = _section == e.id;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: FilterChip(
              showCheckmark: false,
              selected: sel,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(e.icon, size: 16, color: sel ? Colors.white : _muted),
                  const SizedBox(width: 6),
                  Text(e.label, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12, color: sel ? Colors.white : NexaColors.darkNavy)),
                ],
              ),
              selectedColor: _violet,
              backgroundColor: Colors.white,
              side: BorderSide(color: sel ? _violet : _border),
              onSelected: (_) => setState(() => _section = e.id),
            ),
          );
        },
      ),
    );
  }

  Widget _contentCard() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: KeyedSubtree(
        key: ValueKey(_section),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: _sectionBody(),
        ),
      ),
    );
  }

  Widget _sectionBody() {
    switch (_section) {
      case 0:
        return _general();
      case 1:
        return _appearance();
      case 2:
        return _security();
      case 3:
        return _notifications();
      case 4:
        return _users();
      case 5:
        return _payments();
      case 6:
        return _integrations();
      case 7:
        return _learning();
      default:
        return _dataBackup();
    }
  }

  Widget _glassCard({required String title, String? subtitle, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
          if (subtitle != null) ...[const SizedBox(height: 6), Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: _muted, height: 1.4))],
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {String? hint, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        style: GoogleFonts.inter(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, size: 20, color: _muted) : null,
          filled: true,
          fillColor: _surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _violet, width: 1.4)),
        ),
      ),
    );
  }

  Widget _dropdownRow(String label, String value, List<String> items, void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: _surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _border)),
        ),
        items: [for (final x in items) DropdownMenuItem(value: x, child: Text(x, style: GoogleFonts.inter()))],
        onChanged: onChanged,
      ),
    );
  }

  Widget _toggle(String title, String sub, bool v, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14.5)),
                const SizedBox(height: 4),
                Text(sub, style: GoogleFonts.inter(fontSize: 12.5, color: _muted, height: 1.35)),
              ],
            ),
          ),
          Tooltip(
            message: title,
            child: Switch(
              value: v,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: _violet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _general() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _glassCard(
          title: 'Identité & régionalisation',
          subtitle: 'Informations visibles par les apprenants et partenaires.',
          children: [
            _field('Nom de la plateforme', _cPlatform, icon: Icons.public_rounded),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _field('E-mail principal', _cEmail, icon: Icons.mail_outline_rounded)),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: OutlinedButton.icon(
                      onPressed: () => _toast('Sélecteur de logo (démo)'),
                      icon: const Icon(Icons.image_outlined, size: 20),
                      label: Text('Logo', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 22), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), side: const BorderSide(color: _border)),
                    ),
                  ),
                ),
              ],
            ),
            _dropdownRow('Langue', _langue, ['Français (FR)', 'العربية (AR)', 'English (EN)'], (v) => setState(() => _langue = v ?? _langue)),
            _dropdownRow('Fuseau horaire', _fuseau, ['Africa/Casablanca', 'UTC', 'Europe/Paris'], (v) => setState(() => _fuseau = v ?? _fuseau)),
            _dropdownRow('Devise', _devise, ['MAD', 'EUR', 'USD'], (v) => setState(() => _devise = v ?? _devise)),
            _field('URL personnalisée', _cUrl, hint: 'sous-domaine.nexama.ma', icon: Icons.link_rounded),
          ],
        ),
      ],
    );
  }

  Widget _appearance() {
    return Column(
      children: [
        _glassCard(
          title: 'Thème & densité',
          subtitle: 'Ajustez l’ambiance visuelle et la densité des composants.',
          children: [
            _toggle('Mode sombre', 'Interface optimisée pour les environnements peu éclairés.', _darkMode, (v) => setState(() => _darkMode = v)),
            const Divider(height: 32),
            _dropdownRow('Couleur principale', _couleurTheme, ['Violet NexaMa', 'Vert NexaMa', 'Bleu océan'], (v) => setState(() => _couleurTheme = v ?? _couleurTheme)),
            _dropdownRow('Taille des composants', _tailleUi, ['Compact', 'Confort', 'Spacieux'], (v) => setState(() => _tailleUi = v ?? _tailleUi)),
            const SizedBox(height: 12),
            Text('Personnalisation du thème', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _cThemePersonalize,
              maxLines: 3,
              style: GoogleFonts.inter(fontSize: 14, height: 1.45),
              decoration: InputDecoration(
                hintText: 'Notes de design, tokens, variante de marque…',
                filled: true,
                fillColor: _surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _violet, width: 1.4)),
              ),
            ),
            const SizedBox(height: 8),
            Text('Aperçu live', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 10),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, t, _) => Opacity(
                opacity: t,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(colors: [_violet.withValues(alpha: _darkMode ? 0.5 : 0.35), _violetSoft], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                  ),
                  child: Center(child: Text('Prévisualisation NexaMa', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16))),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _security() {
    return Column(
      children: [
        _glassCard(
          title: 'Compte & sessions',
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: _violetSoft, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.password_rounded, color: _violet),
              ),
              title: Text('Modifier le mot de passe', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              subtitle: Text('Dernière mise à jour il y a 32 jours', style: GoogleFonts.inter(fontSize: 12, color: _muted)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _toast('Flux changement mot de passe (démo)'),
            ),
            const Divider(height: 28),
            _toggle('Authentification à deux facteurs (2FA)', 'Renforce la sécurité des comptes administrateurs.', _a2f, (v) => setState(() => _a2f = v)),
            const Divider(height: 28),
            Text('Sessions actives', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(height: 10),
            _miniTable(const ['Appareil', 'Lieu', 'Action'], [
              ['Chrome · Windows', 'Casablanca', 'Révoquer'],
              ['Safari · iOS', 'Rabat', 'Révoquer'],
            ]),
            const SizedBox(height: 16),
            Text('Historique de connexion', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(height: 10),
            _miniTable(const ['Date', 'IP', 'Statut'], [
              ['12 Mai 2026', '41.•••.•••', 'Réussi'],
              ['10 Mai 2026', '105.•••.•••', 'Réussi'],
            ]),
            const SizedBox(height: 18),
            Text('Gestion des appareils connectés', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(height: 6),
            Text('Révoquez un appareil pour forcer une nouvelle authentification.', style: GoogleFonts.inter(fontSize: 12.5, color: _muted, height: 1.35)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  label: Text('Chrome 124 · Windows', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12)),
                  onPressed: () => _toast('Détail appareil (démo)'),
                ),
                ActionChip(
                  label: Text('Safari · iPhone', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12)),
                  onPressed: () => _toast('Détail appareil (démo)'),
                ),
                ActionChip(
                  label: Text('Edge · Windows', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12)),
                  onPressed: () => _toast('Détail appareil (démo)'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _miniTable(List<String> headers, List<List<String>> rows) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(color: _surface, borderRadius: BorderRadius.vertical(top: Radius.circular(13))),
            child: Row(
              children: [
                for (var i = 0; i < headers.length; i++) ...[
                  Expanded(flex: i == headers.length - 1 ? 1 : 2, child: Text(headers[i], style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: _muted))),
                ],
              ],
            ),
          ),
          for (final r in rows)
            Material(
              color: Colors.white,
              child: InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text(r[0], style: GoogleFonts.inter(fontSize: 13))),
                      Expanded(flex: 2, child: Text(r[1], style: GoogleFonts.inter(fontSize: 13, color: _muted))),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(onPressed: () => _toast('Révoqué (démo)'), child: Text(r[2], style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: _violet, fontSize: 12))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _notifications() {
    return Column(
      children: [
        _glassCard(
          title: 'Canaux & alertes',
          children: [
            _toggle('Notifications e-mail', 'Rapports hebdomadaires et alertes importantes.', _notifEmail, (v) => setState(() => _notifEmail = v)),
            _toggle('Notifications push', 'Rappels sur mobile et navigateur.', _notifPush, (v) => setState(() => _notifPush = v)),
            _toggle('Alertes quiz', 'Lorsqu’un apprenant termine ou échoue un quiz.', _alertQuiz, (v) => setState(() => _alertQuiz = v)),
            _toggle('Alertes étudiants', 'Inscriptions, abandons, messages non lus.', _alertEtudiants, (v) => setState(() => _alertEtudiants = v)),
            const Divider(height: 28),
            _toggle('Communications marketing', 'Actualités produit et bonnes pratiques pédagogiques.', _comMarketing, (v) => setState(() => _comMarketing = v)),
          ],
        ),
      ],
    );
  }

  Widget _users() {
    return Column(
      children: [
        _glassCard(
          title: 'Rôles & accès',
          subtitle: 'Contrôlez les permissions sur la plateforme.',
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(onPressed: () => _toast('Ajouter administrateur (démo)'), icon: const Icon(Icons.person_add_alt_1_outlined, size: 20), label: Text('Ajouter administrateur', style: GoogleFonts.inter(fontWeight: FontWeight.w700)), style: FilledButton.styleFrom(backgroundColor: _violet, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
                OutlinedButton.icon(onPressed: () => _toast('Matrice des permissions (démo)'), icon: const Icon(Icons.rule_folder_outlined, size: 20), label: Text('Gérer les rôles', style: GoogleFonts.inter(fontWeight: FontWeight.w600)), style: OutlinedButton.styleFrom(foregroundColor: NexaColors.darkNavy, side: const BorderSide(color: _border), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
                OutlinedButton.icon(onPressed: () => _toast('Gestion des accès (démo)'), icon: const Icon(Icons.lock_person_outlined, size: 20), label: Text('Gestion des accès', style: GoogleFonts.inter(fontWeight: FontWeight.w600)), style: OutlinedButton.styleFrom(foregroundColor: NexaColors.darkNavy, side: const BorderSide(color: _border), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
              ],
            ),
            const SizedBox(height: 18),
            _miniTable(const ['Utilisateur', 'Rôle', 'Action'], [
              ['admin@nexama.ma', 'Super admin', 'Suspendre'],
              ['formateur@nexama.ma', 'Formateur', 'Suspendre'],
            ]),
          ],
        ),
      ],
    );
  }

  Widget _payments() {
    return Column(
      children: [
        _glassCard(
          title: 'Abonnement & facturation',
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(gradient: LinearGradient(colors: [_violet, _violet.withValues(alpha: 0.8)]), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Plan actuel', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('NexaMa Pro', style: GoogleFonts.inter(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        Text('Renouvellement : 1er juin 2026', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toast('Méthodes de paiement (démo)'),
                    icon: const Icon(Icons.credit_card_rounded),
                    label: Text('Méthodes de paiement', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(22), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), side: const BorderSide(color: _border)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text('Transactions récentes', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            _miniTable(const ['Date', 'Montant', 'Statut'], [
              ['08 Mai 2026', '499 MAD', 'Payé'],
              ['01 Mai 2026', '499 MAD', 'Payé'],
            ]),
            const SizedBox(height: 12),
            TextButton.icon(onPressed: () => _toast('Historique factures PDF (démo)'), icon: const Icon(Icons.receipt_long_outlined, size: 20), label: Text('Voir toutes les factures', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: _violet))),
          ],
        ),
      ],
    );
  }

  Widget _integrationRow(String name, String status, bool on, ValueChanged<bool> c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
          Text(status, style: GoogleFonts.inter(fontSize: 12, color: on ? const Color(0xFF059669) : _muted, fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          Switch(value: on, onChanged: c, activeTrackColor: _violet, activeThumbColor: Colors.white),
        ],
      ),
    );
  }

  Widget _integrations() {
    return Column(
      children: [
        _glassCard(
          title: 'Services connectés',
          children: [
            _integrationRow('Google Meet', _intMeet ? 'Connecté' : 'Déconnecté', _intMeet, (v) => setState(() => _intMeet = v)),
            const Divider(),
            _integrationRow('Zoom', _intZoom ? 'Connecté' : 'Déconnecté', _intZoom, (v) => setState(() => _intZoom = v)),
            const Divider(),
            _integrationRow('Stripe', _intStripe ? 'Connecté' : 'Déconnecté', _intStripe, (v) => setState(() => _intStripe = v)),
            const Divider(),
            _integrationRow('PayPal', _intPaypal ? 'Connecté' : 'Déconnecté', _intPaypal, (v) => setState(() => _intPaypal = v)),
            const SizedBox(height: 14),
            _field('Clé API (aperçu)', _cApiKey, icon: Icons.key_outlined),
            const SizedBox(height: 8),
            OutlinedButton.icon(onPressed: () => _toast('Configuration webhooks (démo)'), icon: const Icon(Icons.webhook_outlined), label: Text('Webhooks sortants', style: GoogleFonts.inter(fontWeight: FontWeight.w600)), style: OutlinedButton.styleFrom(foregroundColor: NexaColors.darkNavy, side: const BorderSide(color: _border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
          ],
        ),
      ],
    );
  }

  Widget _learning() {
    return Column(
      children: [
        _glassCard(
          title: 'Parcours & évaluation',
          children: [
            _toggle('Génération automatique de certificats', 'Dès que les conditions sont remplies.', _certifAuto, (v) => setState(() => _certifAuto = v)),
            _toggle('Conditions de réussite (parcours)', 'Modules obligatoires et quiz intermédiaires avant l’examen final.', _conditionsReussite, (v) => setState(() => _conditionsReussite = v)),
            _toggle('Quiz automatiques', 'Assignation après chaque module clôturé.', _quizAuto, (v) => setState(() => _quizAuto = v)),
            const SizedBox(height: 8),
            Text('Score minimal de réussite : $_scoreMinimal %', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            Slider(value: _scoreMinimal.toDouble(), min: 40, max: 100, divisions: 12, activeColor: _violet, label: '$_scoreMinimal', onChanged: (v) => setState(() => _scoreMinimal = v.round())),
            const SizedBox(height: 8),
            Text('Progression moyenne des apprenants', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(value: _progressDemo, minHeight: 10, backgroundColor: _surface, color: _violet),
            ),
            const SizedBox(height: 8),
            Text('${(_progressDemo * 100).round()} % complétion moyenne (démo)', style: GoogleFonts.inter(fontSize: 12, color: _muted)),
          ],
        ),
      ],
    );
  }

  Widget _dataBackup() {
    return Column(
      children: [
        _glassCard(
          title: 'Sauvegarde & export',
          children: [
            _toggle('Sauvegarde automatique nocturne', 'Export chiffré sur stockage sécurisé.', _sauvegardeAuto, (v) => setState(() => _sauvegardeAuto = v)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.tonalIcon(onPressed: () => _toast('Export JSON lancé (démo)'), icon: const Icon(Icons.download_outlined), label: Text('Exporter les données', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                OutlinedButton.icon(onPressed: () => _toast('Rapport PDF (démo)'), icon: const Icon(Icons.picture_as_pdf_outlined), label: Text('Télécharger rapports', style: GoogleFonts.inter(fontWeight: FontWeight.w600)), style: OutlinedButton.styleFrom(side: const BorderSide(color: _border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
                OutlinedButton.icon(onPressed: () => _toast('Restauration (démo)'), icon: const Icon(Icons.restore_rounded), label: Text('Restaurer une sauvegarde', style: GoogleFonts.inter(fontWeight: FontWeight.w600)), style: OutlinedButton.styleFrom(side: const BorderSide(color: _border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
              ],
            ),
          ],
        ),
        _glassCard(
          title: 'Zone sensible',
          subtitle: 'Actions irréversibles sur votre espace.',
          children: [
            OutlinedButton.icon(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    title: Text('Supprimer le compte ?', style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: const Color(0xFFB91C1C))),
                    content: Text('Toutes les données seront définitivement effacées après période de grâce.', style: GoogleFonts.inter(color: _muted, height: 1.45)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
                      FilledButton(onPressed: () { Navigator.pop(ctx); _toast('Demande enregistrée (démo)'); }, style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB91C1C)), child: const Text('Confirmer')),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_forever_outlined, color: Color(0xFFB91C1C)),
              label: Text('Supprimer le compte plateforme', style: GoogleFonts.inter(color: const Color(0xFFB91C1C), fontWeight: FontWeight.w800)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFFECACA)), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            ),
          ],
        ),
      ],
    );
  }
}

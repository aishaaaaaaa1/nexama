import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/formateur/formateur_ui.dart';

class PaiementFormateurPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const PaiementFormateurPage({super.key, this.userData});

  @override
  State<PaiementFormateurPage> createState() => _PaiementFormateurPageState();
}

class _PaiementFormateurPageState extends State<PaiementFormateurPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;

  String get _formateurId => widget.userData?['id']?.toString() ?? 'user_123';

  @override
  void initState() {
    super.initState();
    _fetchPaiementInfo();
  }

  Future<void> _fetchPaiementInfo() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get(ApiConfig.uri('/api/formateur/paiements/$_formateurId'));
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _data = Map<String, dynamic>.from(json.decode(response.body) as Map);
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _editPaymentInfo() async {
    final modeCtrl = TextEditingController(text: _data?['mode']?.toString() ?? 'Virement Bancaire');
    final ribCtrl = TextEditingController(text: _data?['rib']?.toString() ?? '');
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Coordonnées bancaires', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: modeCtrl, decoration: const InputDecoration(labelText: 'Mode de versement', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: ribCtrl, decoration: const InputDecoration(labelText: 'RIB / référence compte', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(ctx, {'mode': modeCtrl.text.trim(), 'rib': ribCtrl.text.trim()}), child: const Text('Enregistrer')),
        ],
      ),
    );
    modeCtrl.dispose();
    ribCtrl.dispose();
    if (result == null || !mounted) return;

    try {
      final response = await ApiService.put(ApiConfig.uri('/api/formateur/paiements/$_formateurId'), body: result);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map && decoded['paiement'] is Map) {
          setState(() => _data = Map<String, dynamic>.from(decoded['paiement'] as Map));
        }
      } else {
        setState(() => _data = {...?_data, ...result, 'statut': 'Configuré'});
      }
    } catch (_) {
      setState(() => _data = {...?_data, ...result, 'statut': 'Configuré'});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const FormateurLoading();

    final configured = _data?['statut']?.toString() == 'Configuré';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FormateurPageHeader(
            title: 'Paiements',
            subtitle: 'Coordonnées bancaires, versements et fonds en attente.',
          ),
          const SizedBox(height: 20),
          FormateurStatsRow(
            items: [
              FormateurStatItem(label: 'En attente', value: _data?['montant_attente']?.toString() ?? '0 MAD', icon: Icons.savings_outlined, color: Colors.orange),
              FormateurStatItem(label: 'Prochain versement', value: _data?['prochain_versement']?.toString() ?? '—', icon: Icons.event, color: NexaColors.primaryGreen),
              FormateurStatItem(label: 'Compte', value: configured ? 'Actif' : 'À configurer', icon: Icons.verified_user_outlined, color: configured ? NexaColors.primaryGreen : Colors.red),
            ],
          ),
          const SizedBox(height: 24),
          FormateurSectionCard(
            title: 'Méthode de versement',
            child: Column(
              children: [
                _paymentMethodTile(icon: Icons.account_balance, title: _data?['mode']?.toString() ?? 'Virement bancaire', subtitle: 'RIB •••• ${_data?['rib'] ?? '4521'}', selected: true),
                const SizedBox(height: 12),
                _paymentMethodTile(icon: Icons.phone_android, title: 'Mobile Money', subtitle: 'Non configuré', selected: false),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FormateurSectionCard(
            child: Column(
              children: [
                _infoRow('Statut du compte', _data?['statut']?.toString() ?? '—', Icons.shield_outlined),
                const Divider(height: 32),
                _infoRow('Montant en attente', _data?['montant_attente']?.toString() ?? '—', Icons.payments_outlined, bold: true),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _editPaymentInfo,
              icon: const Icon(Icons.edit),
              label: const Text('Modifier les coordonnées bancaires'),
              style: FilledButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethodTile({required IconData icon, required String title, required String subtitle, required bool selected}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selected ? FormateurColors.accentLight : FormateurColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? FormateurColors.accent : FormateurColors.border, width: selected ? 1.5 : 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: selected ? FormateurColors.accent : FormateurColors.muted),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: FormateurColors.muted)),
              ],
            ),
          ),
          if (selected) const Icon(Icons.check_circle, color: FormateurColors.accent),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon, {bool bold = false}) {
    return Row(
      children: [
        Icon(icon, color: FormateurColors.muted, size: 22),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: GoogleFonts.inter(color: FormateurColors.muted))),
        Text(value, style: GoogleFonts.inter(fontWeight: bold ? FontWeight.w800 : FontWeight.w600, fontSize: 16, color: bold ? NexaColors.primaryGreen : NexaColors.darkNavy)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../widgets/formateur/formateur_ui.dart';

class RapportsPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const RapportsPage({super.key, this.userData});

  @override
  State<RapportsPage> createState() => _RapportsPageState();
}

class _RapportsPageState extends State<RapportsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _rapports = [];
  String _typeFilter = 'Tous';

  String get _formateurId => widget.userData?['id']?.toString() ?? 'user_123';

  @override
  void initState() {
    super.initState();
    _fetchRapports();
  }

  Future<void> _fetchRapports() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get(ApiConfig.uri('/api/formateur/rapports/$_formateurId'));
      if (response.statusCode == 200 && mounted) {
        final raw = json.decode(response.body) as List<dynamic>;
        setState(() {
          _rapports = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_typeFilter == 'Tous') return _rapports;
    return _rapports.where((r) => '${r['type']}'.contains(_typeFilter)).toList();
  }

  Future<void> _generateReport() async {
    final type = _typeFilter == 'Tous' ? 'VENTES' : _typeFilter;
    try {
      final response = await ApiService.post(ApiConfig.uri('/api/formateur/rapports/$_formateurId'), body: {'type': type});
      if (response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded is Map && decoded['rapport'] is Map && mounted) {
          setState(() => _rapports.insert(0, Map<String, dynamic>.from(decoded['rapport'] as Map)));
        }
      }
    } catch (_) {}
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Génération du rapport en cours…', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
        backgroundColor: FormateurColors.accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const FormateurLoading();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormateurPageHeader(
          title: 'Rapports',
          subtitle: 'Bilans mensuels ventes et performance pédagogique.',
          trailing: ElevatedButton.icon(
            onPressed: _generateReport,
            icon: const Icon(Icons.add_chart, size: 18),
            label: const Text('Générer'),
            style: formateurGreenStyle(),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: ['Tous', 'VENTES', 'ACADÉMIQUE'].map((t) {
            return FormateurChip(label: t == 'Tous' ? t : t[0] + t.substring(1).toLowerCase(), selected: _typeFilter == t, onTap: () => setState(() => _typeFilter = t));
          }).toList(),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _filtered.isEmpty
              ? FormateurEmptyState(icon: Icons.description_outlined, title: 'Aucun rapport', message: 'Générez votre premier bilan.', actionLabel: 'Générer un rapport', onAction: _generateReport)
              : ListView.separated(
                  itemCount: _filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final r = _filtered[i];
                    final isVentes = '${r['type']}'.contains('VENTES');
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: FormateurColors.border)),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (isVentes ? NexaColors.primaryGreen : FormateurColors.accent).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(isVentes ? Icons.payments_outlined : Icons.school_outlined, color: isVentes ? NexaColors.primaryGreen : FormateurColors.accent),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${r['nom']}', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 15)),
                                Text('${r['date']} • ${r['type']}', style: GoogleFonts.inter(fontSize: 12, color: FormateurColors.muted)),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Téléchargement de ${r['nom']}', style: GoogleFonts.inter()), behavior: SnackBarBehavior.floating));
                            },
                            icon: const Icon(Icons.download_outlined, color: NexaColors.darkNavy),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class MarketplacePrestatairePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const MarketplacePrestatairePage({super.key, this.userData});

  @override
  State<MarketplacePrestatairePage> createState() => _MarketplacePrestatairePageState();
}

class _MarketplacePrestatairePageState extends State<MarketplacePrestatairePage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _opportunities = [];
  String _query = '';

  String get _userId => widget.userData?['id']?.toString() ?? 'user_123';

  @override
  void initState() {
    super.initState();
    _fetchOpportunities();
  }

  Future<void> _fetchOpportunities() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get(ApiConfig.uri('/api/prestataire/opportunites/$_userId'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List && mounted) {
          setState(() {
            _opportunities = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _opportunities;
    return _opportunities.where((o) => '${o['titre']} ${o['client']} ${o['tags']}'.toLowerCase().contains(q)).toList();
  }

  Future<void> _apply(Map<String, dynamic> opp) async {
    try {
      final response = await ApiService.post(ApiConfig.uri('/api/prestataire/opportunites/$_userId/${opp['id']}/postuler'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['opportunity'] is Map) {
          final updated = Map<String, dynamic>.from(decoded['opportunity'] as Map);
          setState(() {
            final i = _opportunities.indexWhere((e) => e['id'] == updated['id']);
            if (i >= 0) _opportunities[i] = updated;
          });
        }
      }
    } catch (_) {
      setState(() => opp['statut'] = 'postulé');
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Candidature envoyée pour "${opp['titre']}"'), backgroundColor: NexaColors.primaryGreen, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Marketplace des Opportunités', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                  const Text('Trouvez de nouveaux projets et développez votre activité.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            SizedBox(
              width: 260,
              child: TextField(
                decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Filtrer...', border: OutlineInputBorder()),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Expanded(
          child: _filtered.isEmpty
              ? const Center(child: Text('Aucune opportunité ne correspond au filtre.'))
              : ListView.separated(
                  itemCount: _filtered.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 16),
                  itemBuilder: (context, index) => _buildOpportunityCard(_filtered[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildOpportunityCard(Map<String, dynamic> opp) {
    final tags = (opp['tags'] as List?) ?? const [];
    final applied = opp['statut'] == 'postulé';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('${opp['titre']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
              Text('${opp['budget']}', style: const TextStyle(fontWeight: FontWeight.bold, color: NexaColors.primaryGreen, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Client: ${opp['client']} • Délai: ${opp['delai']}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 16),
          Text('${opp['description']}', style: const TextStyle(height: 1.5)),
          const SizedBox(height: 16),
          Row(
            children: [
              ...tags.map((t) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
                    child: Text('$t', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  )),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: applied ? null : () => _apply(opp),
                icon: Icon(applied ? Icons.check : Icons.send_outlined, size: 16),
                label: Text(applied ? 'Candidature envoyée' : 'Postuler'),
                style: ElevatedButton.styleFrom(backgroundColor: NexaColors.darkNavy, foregroundColor: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class CommandesPrestatairePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const CommandesPrestatairePage({super.key, this.userData});

  @override
  State<CommandesPrestatairePage> createState() => _CommandesPrestatairePageState();
}

class _CommandesPrestatairePageState extends State<CommandesPrestatairePage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _commandes = [];

  String get _userId => widget.userData?['id']?.toString() ?? 'user_123';

  @override
  void initState() {
    super.initState();
    _loadCommandes();
  }

  Future<void> _loadCommandes() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get(ApiConfig.uri('/api/prestataire/commandes/$_userId'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List && mounted) {
          setState(() {
            _commandes = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  void _showSnack(String message, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Mes Commandes B2B', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy))),
            IconButton(tooltip: 'Actualiser', onPressed: _loadCommandes, icon: const Icon(Icons.refresh)),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Gérez vos livraisons et suivez le déblocage de vos fonds.', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        Expanded(
          child: _commandes.isEmpty
              ? const Center(child: Text('Aucune commande pour le moment.'))
              : SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Client')),
                        DataColumn(label: Text('Service')),
                        DataColumn(label: Text('Montant')),
                        DataColumn(label: Text('Statut')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: _commandes.map((c) => _buildRow(c)).toList(),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  DataRow _buildRow(Map<String, dynamic> c) {
    final statut = c['statut']?.toString() ?? '';
    final isEscrow = statut == 'escrow' || statut == 'En cours';
    final isLivree = statut == 'livree';
    final isTerminee = statut == 'terminee' || statut == 'Terminé';
    final color = isTerminee ? Colors.green : (isEscrow ? Colors.orange : Colors.blue);
    final label = isTerminee ? 'Débloqué' : (isEscrow ? 'Fonds bloqués' : 'Attente client');

    return DataRow(cells: [
      DataCell(Text('${c['client']}', style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text('${c['service']}')),
      DataCell(Text('${c['montant']}', style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isTerminee ? Icons.check_circle : (isEscrow ? Icons.lock : Icons.hourglass_empty), size: 12, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      )),
      DataCell(Row(
        children: [
          IconButton(icon: const Icon(Icons.chat_bubble_outline, color: Colors.blue, size: 20), onPressed: () => _showSnack('Ouverture messagerie client...')),
          if (isEscrow)
            ElevatedButton(
              onPressed: () => _livrerCommande(c),
              style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              child: const Text('Livrer', style: TextStyle(fontSize: 12)),
            )
          else if (isLivree)
            const Text('En attente client', style: TextStyle(color: Colors.grey, fontSize: 11))
          else
            const Icon(Icons.check, color: Colors.green),
        ],
      )),
    ]);
  }

  Future<void> _livrerCommande(Map<String, dynamic> c) async {
    final linkCtrl = TextEditingController();
    final link = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la livraison'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Vous êtes sur le point de marquer '${c['service']}' comme livré."),
            const SizedBox(height: 12),
            TextField(controller: linkCtrl, decoration: const InputDecoration(labelText: 'Lien vers les livrables', border: OutlineInputBorder()), maxLines: 2),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, linkCtrl.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            child: const Text('Envoyer les livrables'),
          ),
        ],
      ),
    );
    linkCtrl.dispose();
    if (link == null || !mounted) return;

    var updated = <String, dynamic>{...c, 'statut': 'livree', 'livrable_url': link};
    try {
      final response = await ApiService.put(ApiConfig.uri('/api/prestataire/commandes/$_userId/${c['id']}/livrer'), body: {'livrable_url': link});
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['commande'] is Map) {
          updated = Map<String, dynamic>.from(decoded['commande'] as Map);
        }
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      final i = _commandes.indexWhere((e) => e['id'] == c['id']);
      if (i >= 0) _commandes[i] = updated;
    });
    _showSnack('Livraison envoyée. En attente de validation du client.', color: Colors.blue);
  }
}

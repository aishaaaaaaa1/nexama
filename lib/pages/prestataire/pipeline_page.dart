import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';

class PipelinePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const PipelinePage({super.key, this.userData});

  @override
  State<PipelinePage> createState() => _PipelinePageState();
}

class _PipelinePageState extends State<PipelinePage> {
  bool _isLoading = true;
  List<dynamic> _deals = [];

  final List<String> _colonnes = ['prospects', 'qualifies', 'devis', 'nego', 'gagne'];
  final Map<String, String> _titresColonnes = {
    'prospects': 'PROSPECTS',
    'qualifies': 'QUALIFIÉS',
    'devis': 'DEVIS ENVOYÉ',
    'nego': 'NÉGOCIATION',
    'gagne': 'GAGNÉ'
  };

  @override
  void initState() {
    super.initState();
    _fetchDeals();
  }

  Future<void> _fetchDeals() async {
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final response = await ApiService.get(ApiConfig.uri('/api/prestataire/crm/$userId'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _deals = json.decode(response.body);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addDeal() async {
    final nomController = TextEditingController();
    final montantController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un prospect'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomController, decoration: const InputDecoration(labelText: 'Nom du client/entreprise', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: montantController, decoration: const InputDecoration(labelText: 'Montant estimé (MAD)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (nomController.text.isEmpty) return;
              final userId = widget.userData?['id'] ?? 'user_123';
              final response = await ApiService.post(
                ApiConfig.uri('/api/prestataire/crm/$userId'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode({
                  'client_nom': nomController.text, 
                  'montant_estime': double.tryParse(montantController.text) ?? 0.0
                }),
              );
              if (response.statusCode == 201) {
                if (mounted) Navigator.pop(context);
                _fetchDeals();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            child: const Text('Ajouter'),
          )
        ],
      ),
    );
  }

  Future<void> _updateDealStatus(String dealId, String nouveauStatut) async {
    try {
      final response = await ApiService.put(
        ApiConfig.uri('/api/prestataire/crm/deal/$dealId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'statut': nouveauStatut}),
      );
      if (response.statusCode == 200) {
        _fetchDeals();
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: NexaColors.primaryGreen));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pipeline CRM', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
            ElevatedButton.icon(
              onPressed: _addDeal,
              icon: const Icon(Icons.add),
              label: const Text('Nouveau prospect'),
              style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            )
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _colonnes.map((colonneId) => _buildPipelineColumn(colonneId)).toList(),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildPipelineColumn(String colonneId) {
    final dealsInColumn = _deals.where((d) => d['statut'] == colonneId).toList();

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_titresColonnes[colonneId]!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: NexaColors.darkNavy)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)), child: Text('${dealsInColumn.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                ...dealsInColumn.map((d) => _buildDealCard(d)),
                if (colonneId == 'prospects')
                  InkWell(
                    onTap: _addDeal,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: const Center(child: Icon(Icons.add, color: Colors.grey, size: 24)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDealCard(dynamic deal) {
    final dateStr = deal['updated_at'] != null 
        ? deal['updated_at'].toString().substring(0, 10) 
        : 'Inconnu';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(deal['client_nom'] ?? 'Client', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 16, color: Colors.grey),
                onSelected: (newStatut) => _updateDealStatus(deal['id'], newStatut),
                itemBuilder: (context) => _colonnes.map((c) => PopupMenuItem(value: c, child: Text('Déplacer vers ${_titresColonnes[c]}', style: const TextStyle(fontSize: 12)))).toList(),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text('${deal['montant_estime']} MAD', style: const TextStyle(color: NexaColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          Text('Dernière modif: $dateStr', style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}

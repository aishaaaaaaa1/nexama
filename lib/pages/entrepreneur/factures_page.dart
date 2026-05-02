import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'dart:html' as html; // Used for simulating file downloads on web if needed.
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';

class FacturesPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const FacturesPage({super.key, this.userData});
  @override
  State<FacturesPage> createState() => _FacturesPageState();
}

class _FacturesPageState extends State<FacturesPage> {
  bool _isLoading = true;
  List<dynamic> _factures = [];

  @override
  void initState() {
    super.initState();
    _fetchFactures();
  }

  Future<void> _fetchFactures() async {
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final response = await ApiService.get(ApiConfig.uri('/api/entrepreneur/factures/$userId'));
      if (response.statusCode == 200) {
        if (mounted) setState(() { _factures = json.decode(response.body); _isLoading = false; });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _exportFacturePdf(Map<String, dynamic> facture) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Génération du PDF pour ${facture['numero_ref']} (Simulation)'),
      backgroundColor: Colors.blue,
    ));
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Facture PDF téléchargée avec succès.'),
        backgroundColor: Colors.green,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gestion des Factures', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                const SizedBox(height: 4),
                Text('Facturation conforme DGI (ICE, RC, IF, Patente)', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Export Global (Excel)'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _showAddFactureDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Nouvelle Facture DGI'),
                  style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: _factures.isEmpty
              ? const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("Aucune facture enregistrée.", style: TextStyle(color: Colors.grey))))
              : DataTable(
                  columns: const [
                    DataColumn(label: Text('Référence')),
                    DataColumn(label: Text('Client (ICE)')),
                    DataColumn(label: Text('Date & Échéance')),
                    DataColumn(label: Text('Montant TTC')),
                    DataColumn(label: Text('Statut')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: _factures.map((f) => DataRow(cells: [
                    DataCell(Text(f['numero_ref'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(f['client_nom'] ?? 'Client'),
                        Text('ICE: ${f['client_ice'] ?? 'Non renseigné'}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    )),
                    DataCell(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(f['date_creation'] ?? 'Aujourd\'hui'),
                        Text('Éch: ${f['date_echeance'] ?? 'N/A'}', style: const TextStyle(fontSize: 10, color: Colors.red)),
                      ],
                    )),
                    DataCell(Text('${f['total_ttc']} MAD', style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: (f['statut'] == 'payée' ? Colors.green : Colors.orange).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text((f['statut'] ?? 'en attente').toString().toUpperCase(), style: TextStyle(color: f['statut'] == 'payée' ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                    )),
                    DataCell(Row(
                      children: [
                        IconButton(icon: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 20), tooltip: 'Télécharger PDF', onPressed: () => _exportFacturePdf(f)),
                        IconButton(icon: const Icon(Icons.send, color: Colors.blue, size: 20), tooltip: 'Envoyer par email', onPressed: () {}),
                      ],
                    )),
                  ])).toList(),
                ),
        )
      ],
    );
  }

  void _showAddFactureDialog() {
    final refController = TextEditingController(text: 'F-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}');
    final clientController = TextEditingController();
    final iceClientController = TextEditingController();
    final montantHTController = TextEditingController();
    
    // Auto-Entrepreneur Info (Mocked config)
    String myICE = "001234567890000";
    String myIF = "12345678";
    String myRC = "12345";

    bool tvaApplicable = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          double ht = double.tryParse(montantHTController.text) ?? 0;
          double tva = tvaApplicable ? ht * 0.20 : 0;
          double ttc = ht + tva;

          return AlertDialog(
            title: Text('Nouvelle Facture Conforme DGI', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Vos Mentions Légales', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('ICE: $myICE • IF: $myIF • RC: $myRC', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(controller: refController, decoration: const InputDecoration(labelText: 'Référence Facture', border: OutlineInputBorder())),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: clientController, decoration: const InputDecoration(labelText: 'Nom du Client / Société', border: OutlineInputBorder()))),
                        const SizedBox(width: 12),
                        Expanded(child: TextField(controller: iceClientController, decoration: const InputDecoration(labelText: 'ICE du Client (Obligatoire DGI)', border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: montantHTController,
                      decoration: const InputDecoration(labelText: 'Montant HT (MAD)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Facturer la TVA (20%)', style: TextStyle(fontSize: 14)),
                      subtitle: const Text('Les auto-entrepreneurs sont généralement exonérés (Art 91).', style: TextStyle(fontSize: 12)),
                      value: tvaApplicable,
                      onChanged: (val) => setDialogState(() => tvaApplicable = val),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total TTC calculé : ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${ttc.toStringAsFixed(2)} MAD', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: NexaColors.primaryGreen)),
                      ],
                    )
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
              ElevatedButton.icon(
                onPressed: () async {
                  if (clientController.text.isEmpty || montantHTController.text.isEmpty) return;
                  
                  final body = {
                    'utilisateur_id': widget.userData?['id'] ?? 'user_123',
                    'numero_ref': refController.text,
                    'client_nom': clientController.text,
                    'client_ice': iceClientController.text,
                    'total_ht': ht,
                    'tva': tva,
                    'total_ttc': ttc,
                  };

                  final response = await ApiService.post(
                    ApiConfig.uri('/api/entrepreneur/factures'),
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode(body),
                  );

                  if (response.statusCode == 201) {
                    if (mounted) {
                      Navigator.pop(ctx);
                      _fetchFactures();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Facture générée avec succès'), backgroundColor: Colors.green));
                    }
                  }
                },
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Valider et Créer'),
                style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
              )
            ],
          );
        }
      ),
    );
  }
}

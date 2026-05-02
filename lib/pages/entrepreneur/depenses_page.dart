import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';

class DepensesPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const DepensesPage({super.key, this.userData});

  @override
  State<DepensesPage> createState() => _DepensesPageState();
}

class _DepensesPageState extends State<DepensesPage> {
  bool _isLoading = true;
  List<dynamic> _depenses = [];
  Map<String, double> _categoryTotals = {};

  @override
  void initState() {
    super.initState();
    _fetchDepenses();
  }

  Future<void> _fetchDepenses() async {
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final response = await ApiService.get(ApiConfig.uri('/api/entrepreneur/depenses/$userId'));
      if (response.statusCode == 200) {
        if (mounted) {
          final data = json.decode(response.body) as List<dynamic>;
          _calculateTotals(data);
          setState(() {
            _depenses = data;
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

  void _calculateTotals(List<dynamic> data) {
    _categoryTotals = {};
    for (var d in data) {
      String cat = d['categorie'] ?? 'Autre';
      double montant = double.tryParse(d['montant']?.toString() ?? '0') ?? 0;
      _categoryTotals[cat] = (_categoryTotals[cat] ?? 0) + montant;
    }
  }

  void _simulateBankImport() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Import du relevé bancaire en cours..."),
            Text("Catégorisation automatique par l'IA...", style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // close loading
        setState(() {
          _depenses.insert(0, {'titre': 'Abonnement Adobe', 'categorie': 'Logiciels', 'montant': 600, 'date_depense': 'Aujourd\'hui'});
          _depenses.insert(0, {'titre': 'Carburant', 'categorie': 'Transport', 'montant': 450, 'date_depense': 'Aujourd\'hui'});
          _depenses.insert(0, {'titre': 'Achat Fournitures', 'categorie': 'Achats', 'montant': 1200, 'date_depense': 'Hier'});
          _calculateTotals(_depenses);
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('3 dépenses importées et catégorisées avec succès.'), backgroundColor: Colors.green));
      }
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
                Text('Suivi des Dépenses', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                const SizedBox(height: 4),
                Text('Catégorisation intelligente et import bancaire', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _simulateBankImport,
                  icon: const Icon(Icons.account_balance, size: 18),
                  label: const Text('Importer Relevé (.csv)'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _showAddDepenseDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Nouvelle Dépense'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Historique des Dépenses', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    _depenses.isEmpty
                        ? const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("Aucune dépense enregistrée.", style: TextStyle(color: Colors.grey))))
                        : DataTable(
                            columns: const [
                              DataColumn(label: Text('Titre')),
                              DataColumn(label: Text('Catégorie')),
                              DataColumn(label: Text('Montant')),
                              DataColumn(label: Text('Date')),
                            ],
                            rows: _depenses.map((d) => DataRow(cells: [
                              DataCell(Text(d['titre'] ?? 'N/A')),
                              DataCell(Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                                child: Text(d['categorie'] ?? 'Autre', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                              )),
                              DataCell(Text('${d['montant']} MAD', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent))),
                              DataCell(Text(d['date_depense']?.toString().split('T')[0] ?? 'N/A')),
                            ])).toList(),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Répartition', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: _categoryTotals.entries.map((e) {
                            final i = _categoryTotals.keys.toList().indexOf(e.key);
                            final colors = [NexaColors.primaryGreen, Colors.blue, Colors.orange, Colors.redAccent, Colors.purple];
                            return PieChartSectionData(
                              color: colors[i % colors.length],
                              value: e.value,
                              title: '${((e.value / _categoryTotals.values.fold(0.0, (a, b) => a + b)) * 100).toStringAsFixed(0)}%',
                              radius: 50,
                              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ..._categoryTotals.entries.map((e) {
                      final i = _categoryTotals.keys.toList().indexOf(e.key);
                      final colors = [NexaColors.primaryGreen, Colors.blue, Colors.orange, Colors.redAccent, Colors.purple];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Container(width: 12, height: 12, decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(e.key, style: const TextStyle(fontSize: 12))),
                            Text('${e.value} MAD', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  void _showAddDepenseDialog() {
    final titreController = TextEditingController();
    final montantController = TextEditingController();
    String selectedCategory = 'Achats';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nouvelle Dépense', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titreController, decoration: const InputDecoration(labelText: 'Titre (ex: Achat matériel)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: montantController, decoration: const InputDecoration(labelText: 'Montant (MAD)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(labelText: 'Catégorie', border: OutlineInputBorder()),
              items: ['Achats', 'Transport', 'Logiciels', 'Loyer', 'Marketing', 'Autre']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => selectedCategory = val!,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (titreController.text.isEmpty || montantController.text.isEmpty) return;
              
              final body = {
                'utilisateur_id': widget.userData?['id'] ?? 'user_123',
                'titre': titreController.text,
                'montant': double.tryParse(montantController.text) ?? 0,
                'categorie': selectedCategory,
              };

              final response = await ApiService.post(
                ApiConfig.uri('/api/entrepreneur/depenses'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode(body),
              );

              if (response.statusCode == 201) {
                if (mounted) Navigator.pop(context);
                _fetchDepenses();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Ajouter'),
          )
        ],
      ),
    );
  }
}

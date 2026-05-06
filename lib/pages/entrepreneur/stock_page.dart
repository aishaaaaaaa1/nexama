import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';

class StockPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const StockPage({super.key, this.userData});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<dynamic> _stocks = [];
  String _selectedWarehouse = 'Tous';
  final List<String> _warehouses = ['Tous', 'Casablanca', 'Rabat', 'Tanger'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchStocks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchStocks() async {
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final response = await ApiService.get(ApiConfig.uri('/api/entrepreneur/stock/$userId'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _stocks = json.decode(response.body) ?? [];
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Mock data
          _stocks = [
            {'id': 's1', 'nom': 'MacBook Pro M3', 'quantite': 15, 'seuil_min': 5, 'prix_cmup': 22000, 'entrepot': 'Casablanca', 'sku': 'MBP-M3'},
            {'id': 's2', 'nom': 'iPhone 15 Pro', 'quantite': 3, 'seuil_min': 10, 'prix_cmup': 12500, 'entrepot': 'Casablanca', 'sku': 'IP15-P'},
            {'id': 's3', 'nom': 'Écran Dell 27', 'quantite': 8, 'seuil_min': 5, 'prix_cmup': 4500, 'entrepot': 'Rabat', 'sku': 'DELL-27'},
            {'id': 's4', 'nom': 'Clavier Logitech', 'quantite': 20, 'seuil_min': 10, 'prix_cmup': 1200, 'entrepot': 'Tanger', 'sku': 'LOGI-MX'},
          ];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_stocks == null) return const Center(child: Text('Aucune donnée de stock disponible.'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: NexaColors.primaryGreen,
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: NexaColors.primaryGreen,
          tabs: const [
            Tab(text: 'Inventaire Actuel'),
            Tab(text: 'Mouvements de Stock'),
            Tab(text: 'Analyses & Valeur'),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildInventoryTab(),
              _buildMouvementsTab(),
              _buildAnalysesTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Inventaire & Stock', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
            const Text('Gérez vos marchandises sur plusieurs entrepôts avec traçabilité complète.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          ],
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _showBarcodeSimulator,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scanner Produit'),
              style: ElevatedButton.styleFrom(backgroundColor: NexaColors.darkNavy, foregroundColor: Colors.white),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Nouveau Produit'),
              style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  // --- TABS ---

  Widget _buildInventoryTab() {
    final filtered = _selectedWarehouse == 'Tous' ? _stocks : _stocks.where((s) => s['entrepot'] == _selectedWarehouse).toList();

    return Column(
      children: [
        Row(children: [
          _buildWarehouseFilter(),
          const Spacer(),
          _buildAlertBadge(),
        ]),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Produit')),
                DataColumn(label: Text('SKU')),
                DataColumn(label: Text('Entrepôt')),
                DataColumn(label: Text('Stock')),
                DataColumn(label: Text('Action')),
              ],
              rows: filtered.map((s) {
                int qty = s['quantite'] ?? 0;
                int seuil = s['seuil_min'] ?? 0;
                bool isLow = qty < seuil;
                return DataRow(cells: [
                  DataCell(Text(s['nom'] ?? 'Produit', style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(s['sku'] ?? '-')),
                  DataCell(Text(s['entrepot'] ?? '-')),
                  DataCell(Row(children: [
                    Text('$qty', style: TextStyle(color: isLow ? Colors.red : Colors.black, fontWeight: isLow ? FontWeight.bold : FontWeight.normal)),
                    if (isLow) const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.warning_amber_rounded, color: Colors.red, size: 16)),
                  ])),
                  DataCell(IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined, size: 18))),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMouvementsTab() {
    return ListView(
      children: [
        _movementItem('Entrée', 'MacBook Pro M3', '+5', 'Casablanca', '20/05/2024'),
        _movementItem('Sortie', 'iPhone 15 Pro', '-2', 'Casablanca', '19/05/2024'),
        _movementItem('Transfert', 'Clavier Logitech', '10', 'Rabat -> Tanger', '18/05/2024'),
        _movementItem('Entrée', 'Écran Dell 27', '+12', 'Rabat', '15/05/2024'),
      ],
    );
  }

  String _valuationMethod = 'CMUP';

  Widget _buildAnalysesTab() {
    double totalVal = _stocks.fold(0.0, (sum, s) {
      double price = (s['prix_cmup'] ?? 0.0).toDouble();
      if (_valuationMethod == 'FIFO') price = price * 1.05; // Simulation : FIFO est souvent légèrement plus élevé en période d'inflation
      return sum + ((s['quantite'] ?? 0) * price);
    });
    
    return Column(
      children: [
        Row(children: [
          _buildValuationCard('Valeur totale du stock', '${totalVal.toInt()} MAD', Icons.monetization_on, NexaColors.primaryGreen),
          const SizedBox(width: 16),
          _buildValuationCard('Nb Références', '${_stocks.length}', Icons.inventory_2, Colors.blue),
        ]),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Méthode de valorisation', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                ToggleButtons(
                  borderRadius: BorderRadius.circular(8),
                  isSelected: [_valuationMethod == 'CMUP', _valuationMethod == 'FIFO'],
                  onPressed: (index) {
                    setState(() {
                      _valuationMethod = index == 0 ? 'CMUP' : 'FIFO';
                    });
                  },
                  children: const [
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('CMUP')),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('FIFO')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _valuationMethod == 'CMUP' 
                ? 'Le CMUP (Coût Moyen Unitaire Pondéré) lisse les variations de prix d\'achat.' 
                : 'Le FIFO (First-In, First-Out) valorise le stock aux prix d\'achat les plus récents.',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _valuationRow('Marchandises', '85%', totalVal * 0.85),
            _valuationRow('Fournitures', '15%', totalVal * 0.15),
          ]),
        ),
      ],
    );
  }

  // --- WIDGETS ---

  Widget _buildWarehouseFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: DropdownButton<String>(
        value: _selectedWarehouse,
        underline: const SizedBox(),
        onChanged: (v) => setState(() => _selectedWarehouse = v!),
        items: _warehouses.map((w) => DropdownMenuItem(value: w, child: Text(w, style: const TextStyle(fontSize: 13)))).toList(),
      ),
    );
  }

  Widget _buildAlertBadge() {
    int lowCount = _stocks.where((s) => (s['quantite'] ?? 0) < (s['seuil_min'] ?? 0)).length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.withOpacity(0.3))),
      child: Row(children: [
        const Icon(Icons.notifications_active, color: Colors.red, size: 16),
        const SizedBox(width: 8),
        Text('$lowCount produits en rupture ou seuil critique', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
      ]),
    );
  }

  Widget _movementItem(String type, String prod, String qty, String loc, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(children: [
        Icon(type == 'Entrée' ? Icons.arrow_downward : type == 'Sortie' ? Icons.arrow_upward : Icons.swap_horiz, color: type == 'Entrée' ? Colors.green : Colors.orange),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(prod, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('$loc | $date', style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ])),
        Text(qty, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: qty.startsWith('+') ? Colors.green : Colors.orange)),
      ]),
    );
  }

  Widget _buildValuationCard(String label, String val, IconData icon, Color color) {
    return Expanded(child: Container(padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
          Text(val, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20)),
        ]),
      ]),
    ));
  }

  Widget _valuationRow(String label, String percent, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text('${amount.toInt()} MAD ($percent)'),
        ]),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: double.parse(percent.replaceAll('%', '')) / 100, backgroundColor: const Color(0xFFF1F5F9), valueColor: AlwaysStoppedAnimation(NexaColors.primaryGreen), borderRadius: BorderRadius.circular(4)),
      ]),
    );
  }

  void _showBarcodeSimulator() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Simulateur Scanner Code-Barre'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(height: 200, width: 300, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(8)), child: const Center(child: Icon(Icons.qr_code_2, size: 100, color: Colors.black54))),
          const SizedBox(height: 16),
          const Text('Placez le code-barre du produit face à la caméra...'),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(onPressed: () {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produit "iPhone 15 Pro" détecté. Stock mis à jour (+1)'), backgroundColor: Colors.green));
            setState(() { _stocks[1]['quantite']++; });
          }, child: const Text('Simuler Détection (SKU: IP15-P)')),
        ],
      )
    );
  }
}

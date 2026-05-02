import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class ComptabilitePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const ComptabilitePage({super.key, this.userData});

  @override
  State<ComptabilitePage> createState() => _ComptabilitePageState();
}

class _ComptabilitePageState extends State<ComptabilitePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Trimestre en cours';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            Tab(text: 'Tableau de bord'),
            Tab(text: 'Journal & Bilan'),
            Tab(text: 'TVA & DGI'),
            Tab(text: 'Banque & Export'),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildJournalBilanTab(),
              _buildTvaDgiTab(),
              _buildBankExportTab(),
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
            Text('Comptabilité & Finance', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
            Text('Période : $_selectedPeriod', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          ],
        ),
        _buildPeriodSelector(),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: DropdownButton<String>(
        value: _selectedPeriod,
        underline: const SizedBox(),
        onChanged: (val) => setState(() => _selectedPeriod = val!),
        items: ['Mois en cours', 'Trimestre en cours', 'Année 2024'].map((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 13)));
        }).toList(),
      ),
    );
  }

  // --- TABS ---

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildAlertsSection(),
          const SizedBox(height: 24),
          _buildFiscalOverview(),
          const SizedBox(height: 24),
          _buildRecouvrementStats(),
        ],
      ),
    );
  }

  Widget _buildJournalBilanTab() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildJournal()),
        const SizedBox(width: 24),
        Expanded(flex: 2, child: _buildBilanSimplifie()),
      ],
    );
  }

  Widget _buildTvaDgiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Déclaration de TVA (Conforme DGI)', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              children: [
                _buildTvaRow('TVA Collectée (Ventes)', '17 080 MAD', true),
                const Divider(height: 32),
                _buildTvaRow('TVA Déductible (Achats)', '8 420 MAD', false),
                const Divider(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: NexaColors.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: _buildTvaRow('TVA Net à payer', '8 660 MAD', true, isTotal: true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showFeedback('Déclaration générée pour la DGI'),
            icon: const Icon(Icons.send_outlined),
            label: const Text('Télédéclarer sur SIMPL-TVA'),
            style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.all(20)),
          ),
        ],
      ),
    );
  }

  Widget _buildBankExportTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildBankIntegrationCard(),
          const SizedBox(height: 24),
          _buildExportCard(),
        ],
      ),
    );
  }

  // --- SUB WIDGETS ---

  Widget _buildAlertsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFFEBA1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFF856404), size: 24),
              const SizedBox(width: 10),
              Text('Rappels Fiscaux & Sociaux', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF856404))),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _taxAlert('TVA (Trimestrielle)', '20 Juil. 2024', true),
              _taxAlert('CNSS', '10 Juil. 2024', true),
              _taxAlert('IR / Chiffre d\'Affaires', '31 Juil. 2024', false),
            ],
          )
        ],
      ),
    );
  }

  Widget _taxAlert(String title, String date, bool isUrgent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: isUrgent ? Colors.red.withOpacity(0.3) : const Color(0xFFE2E8F0))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: 14, color: isUrgent ? Colors.red : Colors.grey),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              Text('Échéance : $date', style: TextStyle(color: isUrgent ? Colors.red : Colors.grey, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFiscalOverview() {
    return Row(
      children: [
        _buildFiscalCard('Chiffre d\'Affaires', '85 400 MAD', '+12% vs m-1', Icons.show_chart, Colors.blue),
        const SizedBox(width: 16),
        _buildFiscalCard('Bénéfice Net (Est.)', '52 000 MAD', '+5% vs m-1', Icons.account_balance, NexaColors.primaryGreen),
        const SizedBox(width: 16),
        _buildFiscalCard('Charges Totales', '33 400 MAD', '-2% vs m-1', Icons.trending_down, Colors.redAccent),
      ],
    );
  }

  Widget _buildFiscalCard(String title, String val, String sub, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              Icon(icon, size: 16, color: color),
            ]),
            const SizedBox(height: 12),
            Text(val, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(sub, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildJournal() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Journal Automatique des Opérations', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          _buildJournalEntry('VENTE', 'Facture F-2024-001', '+ 15 000 MAD', '15/05', 'Validé'),
          _buildJournalEntry('ACHAT', 'Location Bureau', '- 4 500 MAD', '12/05', 'Validé'),
          _buildJournalEntry('VENTE', 'Prestation Cloud', '+ 8 500 MAD', '10/05', 'Validé'),
          _buildJournalEntry('FRAIS', 'Publicité Google', '- 1 200 MAD', '08/05', 'En attente'),
        ],
      ),
    );
  }

  Widget _buildJournalEntry(String type, String label, String amount, String date, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: (type == 'VENTE' ? Colors.green : Colors.red).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(type, style: TextStyle(color: type == 'VENTE' ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text(date, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ])),
          Text(amount, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: amount.startsWith('+') ? Colors.green : Colors.red)),
        ],
      ),
    );
  }

  Widget _buildBilanSimplifie() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: NexaColors.darkNavy, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bilan Simplifié', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          _bilanRow('ACTIF (Trésorerie, Clients)', '142 500 MAD', Colors.white),
          const SizedBox(height: 8),
          _bilanRow('PASSIF (Dettes, Fournisseurs)', '28 400 MAD', Colors.white70),
          const Divider(color: Colors.white24, height: 32),
          _bilanRow('Capitaux Propres', '114 100 MAD', NexaColors.primaryGreen, isTotal: true),
        ],
      ),
    );
  }

  Widget _bilanRow(String label, String val, Color color, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: isTotal ? 16 : 13)),
      ],
    );
  }

  Widget _buildTvaRow(String label, String val, bool isPositive, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 15 : 13, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(val, style: GoogleFonts.inter(fontSize: isTotal ? 18 : 14, fontWeight: FontWeight.bold, color: isPositive ? NexaColors.darkNavy : Colors.redAccent)),
      ],
    );
  }

  Widget _buildBankIntegrationCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.account_balance, color: Colors.blue),
            const SizedBox(width: 12),
            Text('Intégration Bancaire', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
          ]),
          const SizedBox(height: 16),
          const Text('Synchronisez vos comptes bancaires marocains (BMCE, Attijari, BCP...) pour un import automatique des relevés.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showFeedback('Connexion bancaire établie (Simulation)'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            child: const Text('Connecter mon compte bancaire'),
          ),
        ],
      ),
    );
  }

  Widget _buildExportCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Exports Expert-Comptable', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          const Text('Exportez vos données comptables compatibles avec les logiciels Cegid, Sage, Odoo.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 24),
          Row(
            children: [
              _exportBtn('Format Excel', Icons.table_chart),
              const SizedBox(width: 12),
              _exportBtn('Format CSV', Icons.description),
            ],
          ),
        ],
      ),
    );
  }

  Widget _exportBtn(String label, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () => _showFeedback('Fichier généré avec succès'),
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: NexaColors.darkNavy, elevation: 0, side: const BorderSide(color: Color(0xFFE2E8F0))),
    );
  }

  Widget _buildRecouvrementStats() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Trésorerie & Prévisions', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 20),
        const Text('Flux de trésorerie net (Projection 3 mois)', style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 12),
        Container(height: 150, width: double.infinity, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('Graphique de Trésorerie (Généré)', style: TextStyle(color: Colors.grey)))),
      ]),
    );
  }

  void _showFeedback(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: NexaColors.primaryGreen));
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../../theme/app_theme.dart';
import '../../../config/api_config.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import 'dart:html' as html;

class FinanceDashboard extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const FinanceDashboard({super.key, this.userData});

  @override
  State<FinanceDashboard> createState() => _FinanceDashboardState();
}

class _FinanceDashboardState extends State<FinanceDashboard> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {
    'total_ca': 0,
    'total_expenses': 0,
    'net_profit': 0,
    'pending_payments': 0,
    'recovery_rate': '0',
    'cashflow_forecast': 0
  };
  List<dynamic> _invoices = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      await Future.wait([
        _fetchStats(),
        _fetchInvoices(),
      ]);
    } catch (e) {
      debugPrint('General error loading finance data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchStats() async {
    try {
      final response = await ApiService.get(ApiConfig.uri('/api/finance/stats'));
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _stats = json.decode(response.body);
        });
      }
    } catch (e) {
      debugPrint('Error fetching stats: $e');
    }
  }

  Future<void> _fetchInvoices() async {
    try {
      final response = await ApiService.get(ApiConfig.uri('/api/finance/invoices'));
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _invoices = json.decode(response.body);
        });
      }
    } catch (e) {
      debugPrint('Error fetching invoices: $e');
    }
  }

  Future<void> _downloadInvoice(String id, String ref) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Préparation du PDF : $ref...')));
      final response = await ApiService.get(ApiConfig.uri('/api/finance/invoices/$id/download'));
      if (response.statusCode == 200) {
        final blob = html.Blob([response.bodyBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'Facture_$ref.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
      }
    } catch (e) {
      debugPrint('Error downloading: $e');
    }
  }

  Future<void> _sendInvoiceByEmail(String id, String ref) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Envoi de la facture $ref par email...')));
      final response = await ApiService.post(ApiConfig.uri('/api/finance/invoices/$id/send-email'), body: {});
      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email envoyé avec succès !'), backgroundColor: Colors.green));
        _fetchInvoices();
      }
    } catch (e) {
      debugPrint('Error sending email: $e');
    }
  }

  Future<void> _downloadReport(String type) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Génération du rapport $type...')));
      final response = await ApiService.get(ApiConfig.uri('/api/finance/reports/$type'));
      if (response.statusCode == 200) {
        final blob = html.Blob([response.bodyBytes], type == 'pdf' ? 'application/pdf' : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', type == 'pdf' ? 'Synthese_Financiere.pdf' : 'Rapport_Financier.xlsx')
          ..click();
        html.Url.revokeObjectUrl(url);
      }
    } catch (e) {
      debugPrint('Error downloading report: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: NexaColors.primaryGreen),
            const SizedBox(height: 16),
            Text('Chargement de vos finances...', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildKpiRow(),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildCashflowChart()),
              const SizedBox(width: 24),
              Expanded(flex: 1, child: _buildTaxReminders()),
            ],
          ),
          const SizedBox(height: 32),
          _buildRecentInvoices(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gestion Financière', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
            const SizedBox(height: 4),
            Text('Suivez votre trésorerie et vos obligations fiscales.', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => _downloadReport('pdf'),
              icon: const Icon(Icons.picture_as_pdf, size: 18),
              label: const Text('Synthèse PDF'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.blueAccent),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () => _downloadReport('excel'),
              icon: const Icon(Icons.table_chart, size: 18),
              label: const Text('Exporter Excel'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.green),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nouvelle Facture'),
              style: ElevatedButton.styleFrom(
                backgroundColor: NexaColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiRow() {
    return Row(
      children: [
        Expanded(child: _buildKpiCard('Chiffre d\'Affaires', '${_stats['total_ca'] ?? 0} MAD', Icons.trending_up, NexaColors.primaryGreen)),
        const SizedBox(width: 16),
        Expanded(child: _buildKpiCard('Dépenses Totales', '${_stats['total_expenses'] ?? 0} MAD', Icons.trending_down, Colors.redAccent)),
        const SizedBox(width: 16),
        Expanded(child: _buildKpiCard('Bénéfice Net', '${_stats['net_profit'] ?? 0} MAD', Icons.account_balance_wallet, Colors.blueAccent)),
        const SizedBox(width: 16),
        Expanded(child: _buildKpiCard('En Attente', '${_stats['pending_payments'] ?? 0} MAD', Icons.timer, Colors.orangeAccent)),
      ],
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
        ],
      ),
    );
  }

  Widget _buildCashflowChart() {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Évolution de la Trésorerie', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          const Text('Prévisions basées sur vos factures et dépenses récurrentes.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const Spacer(),
          Center(
            child: Column(
              children: [
                const Icon(Icons.bar_chart, size: 100, color: Color(0xFFE2E8F0)),
                Text('Graphique Prévisionnel', style: TextStyle(color: Colors.grey[400])),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildTaxReminders() {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: NexaColors.darkNavy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fiscalité & CNSS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          _buildTaxItem('TVA Trimestre 2', 'Dans 12 jours', Colors.orange),
          _buildTaxItem('Cotisation CNSS', 'Payé', Colors.green),
          _buildTaxItem('Déclaration IR', 'Juin 2024', Colors.white30),
          const Spacer(),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.1), foregroundColor: Colors.white, elevation: 0),
            child: const Center(child: Text('Voir tout le calendrier')),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxItem(String title, String deadline, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              Text(deadline, style: TextStyle(color: color, fontSize: 12)),
            ],
          ),
          Icon(Icons.notifications_none, color: color, size: 18),
        ],
      ),
    );
  }

  Widget _buildRecentInvoices() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Factures Récentes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              TextButton(onPressed: () {}, child: const Text('Voir tout')),
            ],
          ),
          const SizedBox(height: 16),
          if (_invoices.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Aucune facture pour le moment.', style: TextStyle(color: Colors.grey))))
          else
            ..._invoices.take(5).map((inv) {
              Color color = Colors.orange;
              if (inv['statut'] == 'payee') color = Colors.green;
              if (inv['statut'] == 'en_retard') color = Colors.red;
              
              return _buildInvoiceRow(
                inv['id'],
                inv['numero_ref'] ?? 'N/A', 
                inv['client_nom'] ?? 'Client', 
                '${inv['total_ttc']} MAD', 
                inv['statut'] ?? 'Brouillon', 
                color
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(String id, String ref, String client, String amount, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ref, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(client, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(width: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => _downloadInvoice(id, ref),
            icon: const Icon(Icons.download_rounded, size: 20, color: NexaColors.primaryGreen),
            tooltip: 'Télécharger PDF',
          ),
          IconButton(
            onPressed: () => _sendInvoiceByEmail(id, ref),
            icon: const Icon(Icons.email_outlined, size: 20, color: Colors.blueAccent),
            tooltip: 'Envoyer par email',
          ),
        ],
      ),
    );
  }
}

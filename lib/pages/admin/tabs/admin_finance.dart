import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class AdminFinance extends StatelessWidget {
  const AdminFinance({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gestion Financière & Escrow', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildBalanceCard('Fonds en Escrow', '1,245,000 MAD', Icons.lock_outline, Colors.blue),
            const SizedBox(width: 16),
            _buildBalanceCard('Commissions Platform', '84,500 MAD', Icons.trending_up, NexaColors.primaryGreen),
            const SizedBox(width: 16),
            _buildBalanceCard('Retraits en attente', '12,000 MAD', Icons.payments_outlined, Colors.orange),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Transactions de la Plateforme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 20),
              _buildTransactionItem('ID-9842', 'Achat de Service (Escrow)', '+ 15,000 MAD', 'Payé'),
              const Divider(),
              _buildTransactionItem('ID-9843', 'Abonnement Premium (Stripe)', '+ 490 MAD', 'Payé'),
              const Divider(),
              _buildTransactionItem('ID-9844', 'Retrait Prestataire', '- 3,200 MAD', 'En cours'),
              const Divider(),
              _buildTransactionItem('ID-9845', 'Libération Escrow', '- 12,000 MAD', 'Payé'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(String label, String val, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 16),
            Text(val, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(String id, String desc, String amount, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
            child: Text(id, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(desc, style: const TextStyle(fontWeight: FontWeight.w500))),
          Text(amount, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: amount.startsWith('+') ? Colors.green : Colors.red)),
          const SizedBox(width: 24),
          _buildStatusTag(status),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    Color color = status == 'Payé' ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

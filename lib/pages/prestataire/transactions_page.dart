import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'dart:convert';

class TransactionsPrestatairePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const TransactionsPrestatairePage({super.key, this.userData});

  @override
  State<TransactionsPrestatairePage> createState() => _TransactionsPrestatairePageState();
}

class _TransactionsPrestatairePageState extends State<TransactionsPrestatairePage> {
  bool _isLoading = true;
  List<dynamic> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final response = await ApiService.get(ApiConfig.uri('/api/prestataire/transactions/$userId'));
      if (response.statusCode == 200) {
        setState(() {
          _transactions = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transactions & Paiements', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
            const Text('Suivi de vos revenus et versements.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _transactions.length,
                separatorBuilder: (c, i) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final tx = _transactions[index];
                  final bool isTermine = (tx['statut'] ?? '') == 'Terminé';
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    leading: CircleAvatar(
                      backgroundColor: (isTermine ? Colors.green : Colors.orange).withOpacity(0.1),
                      child: Icon(isTermine ? Icons.check : Icons.access_time, color: isTermine ? Colors.green : Colors.orange),
                    ),
                    title: Text(tx['description'] ?? 'Transaction sans description', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(tx['date'] ?? 'Date inconnue'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(tx['montant'] ?? '0 MAD', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: NexaColors.darkNavy)),
                        Text(tx['statut'] ?? 'En attente', style: TextStyle(color: isTermine ? Colors.green : Colors.orange, fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

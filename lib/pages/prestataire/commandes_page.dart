import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class CommandesPrestatairePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const CommandesPrestatairePage({super.key, this.userData});

  @override
  State<CommandesPrestatairePage> createState() => _CommandesPrestatairePageState();
}

class _CommandesPrestatairePageState extends State<CommandesPrestatairePage> {
  List<dynamic> _commandes = [];

  @override
  void initState() {
    super.initState();
    _loadCommandes();
  }

  void _loadCommandes() {
    _commandes = [
      {'id': 'cmd_001', 'client': 'Ayoub El Fassi', 'service': 'Création Site Vitrine', 'montant': '5000 MAD', 'statut': 'escrow', 'echeance': '18 Mai 2024'},
      {'id': 'cmd_002', 'client': 'Youssef B.', 'service': 'Audit SEO', 'montant': '1500 MAD', 'statut': 'terminee', 'echeance': '10 Mai 2024'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mes Commandes B2B', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
        const SizedBox(height: 8),
        const Text("Gérez vos livraisons et suivez le déblocage de vos fonds (Escrow).", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Client')),
              DataColumn(label: Text('Service')),
              DataColumn(label: Text('Montant (Escrow)')),
              DataColumn(label: Text('Statut Paiement')),
              DataColumn(label: Text('Action')),
            ],
            rows: _commandes.map((c) {
              bool isEscrow = c['statut'] == 'escrow';
              bool isLivree = c['statut'] == 'livree'; // Attente client
              bool isTerminee = c['statut'] == 'terminee';

              return DataRow(cells: [
                DataCell(Text(c['client'], style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(c['service'])),
                DataCell(Text(c['montant'], style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: isTerminee ? Colors.green.withOpacity(0.1) : (isEscrow ? Colors.orange.withOpacity(0.1) : Colors.blue.withOpacity(0.1)), borderRadius: BorderRadius.circular(4)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isTerminee ? Icons.check_circle : (isEscrow ? Icons.lock : Icons.hourglass_empty), size: 12, color: isTerminee ? Colors.green : (isEscrow ? Colors.orange : Colors.blue)),
                        const SizedBox(width: 4),
                        Text(isTerminee ? 'Débloqué' : (isEscrow ? 'Fonds bloqués' : 'Attente validation'), style: TextStyle(color: isTerminee ? Colors.green : (isEscrow ? Colors.orange : Colors.blue), fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.chat_bubble_outline, color: Colors.blue, size: 20), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ouverture messagerie client...')))),
                      if (isEscrow)
                        ElevatedButton(
                          onPressed: () => _livrerCommande(c),
                          style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                          child: const Text('Livrer', style: TextStyle(fontSize: 12)),
                        )
                      else if (!isTerminee)
                        const Text('En attente client', style: TextStyle(color: Colors.grey, fontSize: 11))
                      else
                        const Icon(Icons.check, color: Colors.green)
                    ],
                  )
                ),
              ]);
            }).toList(),
          ),
        )
      ],
    );
  }

  void _livrerCommande(dynamic c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la livraison'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Vous êtes sur le point de marquer '${c['service']}' comme livré."),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(labelText: 'Lien vers les livrables (Fichiers, Drive)', border: OutlineInputBorder()), maxLines: 2),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              setState(() => c['statut'] = 'livree');
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Livraison envoyée ! En attente de validation du client pour débloquer les fonds.'), backgroundColor: Colors.blue));
            },
            style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            child: const Text('Envoyer les livrables'),
          ),
        ],
      ),
    );
  }
}

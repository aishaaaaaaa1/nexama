import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'dart:convert';

class DocumentsPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const DocumentsPage({super.key, this.userData});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  bool _isLoading = true;
  List<dynamic> _documents = [];

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  Future<void> _fetchDocuments() async {
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final response = await ApiService.get(ApiConfig.uri('/api/invest/documents/$userId'));
      if (response.statusCode == 200) {
        setState(() {
          _documents = json.decode(response.body);
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Documents', style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Vos contrats et attestations liés à vos investissements.', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 24),
        if (_documents.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: const Center(child: Text("Aucun document juridique trouvé.", style: TextStyle(color: Colors.grey))),
          )
        else
          Expanded(
            child: ListView.separated(
              itemCount: _documents.length,
              separatorBuilder: (c, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final doc = _documents[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: NexaColors.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.description, color: NexaColors.primaryGreen),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doc['nom'] ?? 'Document', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('${doc['date'] ?? ''} • ${doc['taille'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.download, color: Colors.grey)),
                    ],
                  ),
                );
              },
            ),
          )
      ],
    );
  }
}

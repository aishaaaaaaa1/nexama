import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'dart:convert';

class DocumentsPrestatairePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const DocumentsPrestatairePage({super.key, this.userData});

  @override
  State<DocumentsPrestatairePage> createState() => _DocumentsPrestatairePageState();
}

class _DocumentsPrestatairePageState extends State<DocumentsPrestatairePage> {
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
      final response = await ApiService.get(ApiConfig.uri('/api/prestataire/documents/$userId'));
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
        Text('Documents Administratifs', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
        const Text('Accédez à vos contrats, factures et attestations.', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.5),
            itemCount: _documents.length,
            itemBuilder: (context, index) {
              final doc = _documents[index];
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(doc['type'] == 'PDF' ? Icons.picture_as_pdf : Icons.image, color: doc['type'] == 'PDF' ? Colors.red : Colors.blue, size: 40),
                    const SizedBox(height: 16),
                    Text(doc['nom'], textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('${doc['date']} • ${doc['taille']}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    const Spacer(),
                    TextButton.icon(onPressed: () {}, icon: const Icon(Icons.download, size: 16), label: const Text('Télécharger'))
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

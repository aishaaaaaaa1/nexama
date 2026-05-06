import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'dart:convert';
import '../shared/chat_page.dart';

class MessagesPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const MessagesPage({super.key, this.userData});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  bool _isLoading = true;
  List<dynamic> _conversations = [];

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    try {
      final response = await ApiService.get(ApiConfig.uri('/api/messages/conversations'));
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _conversations = json.decode(response.body);
          // Décoder Base64
          for (var c in _conversations) {
            try {
              c['lastMessage'] = utf8.decode(base64.decode(c['lastMessage']));
            } catch (_) {}
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Messages Sécurisés', style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Échanges sécurisés avec les entrepreneurs et l\'administration.', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 24),
        if (_conversations.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("Aucune conversation trouvée.", style: TextStyle(color: Colors.grey))))
        else
          Expanded(
            child: ListView.separated(
              itemCount: _conversations.length,
              separatorBuilder: (c, i) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final c = _conversations[index];
                final user = c['user'];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: NexaColors.primaryGreen.withOpacity(0.1),
                    child: Text(user['nom_complet']?[0] ?? '?', style: const TextStyle(color: NexaColors.primaryGreen, fontWeight: FontWeight.bold)),
                  ),
                  title: Row(
                    children: [
                      Text(user['nom_complet'] ?? 'Inconnu', style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (c['unread'] == true)
                        Container(margin: const EdgeInsets.only(left: 8), width: 8, height: 8, decoration: const BoxDecoration(color: NexaColors.primaryGreen, shape: BoxShape.circle)),
                    ],
                  ),
                  subtitle: Text(c['lastMessage'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Text('Auj.', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(otherUser: user, userData: widget.userData)));
                    _fetchConversations();
                  },
                );
              },
            ),
          )
      ],
    );
  }

  void _showConversationDialog(Map<String, dynamic> msg) {
    final repController = TextEditingController();
    
    // Initialize history if not present
    if (msg['historique'] == null) {
      msg['historique'] = [
        {'texte': msg['texte'], 'date': msg['date'], 'isMe': false}
      ];
    }
    
    List<dynamic> thread = msg['historique'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(backgroundColor: NexaColors.primaryGreen.withOpacity(0.1), child: Text(msg['expediteur'][0], style: const TextStyle(color: NexaColors.primaryGreen, fontWeight: FontWeight.bold))),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(msg['expediteur'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                                child: Text(msg['role']?.toString().toUpperCase() ?? 'INCONNU', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                              )
                            ],
                          )
                        ],
                      ),
                      IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: thread.length,
                    itemBuilder: (context, i) => _buildBubble(thread[i]['texte'], thread[i]['date'], thread[i]['isMe']),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 20, right: 20, top: 10),
                  decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE2E8F0)))),
                  child: Row(
                    children: [
                      Expanded(child: TextField(controller: repController, decoration: const InputDecoration(hintText: 'Écrire un message...', border: OutlineInputBorder()))),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (repController.text.isNotEmpty) {
                            setModalState(() {
                              thread.add({'texte': repController.text, 'date': "À l'instant", 'isMe': true});
                              repController.clear();
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
                        child: const Icon(Icons.send, size: 20),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildBubble(String text, String date, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? NexaColors.primaryGreen : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12).copyWith(bottomLeft: Radius.circular(isMe ? 12 : 0), bottomRight: Radius.circular(isMe ? 0 : 12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: TextStyle(color: isMe ? Colors.white : NexaColors.darkNavy, fontSize: 14)),
            const SizedBox(height: 4),
            Text(date, style: TextStyle(color: isMe ? Colors.white70 : const Color(0xFF94A3B8), fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

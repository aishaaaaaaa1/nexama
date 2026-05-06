import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> otherUser; // Correspondant
  final Map<String, dynamic>? userData; // Utilisateur actuel
  
  const ChatPage({super.key, required this.otherUser, this.userData});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    try {
      final response = await ApiService.get(ApiConfig.uri('/api/messages/${widget.otherUser['id']}'));
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _messages = json.decode(response.body);
          // Décoder le contenu Base64 pour l'affichage
          for (var m in _messages) {
            try {
              m['contenu'] = utf8.decode(base64.decode(m['contenu']));
            } catch (_) {}
          }
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_msgController.text.trim().isEmpty) return;
    
    final text = _msgController.text.trim();
    _msgController.clear();

    try {
      final response = await ApiService.post(
        ApiConfig.uri('/api/messages/send'),
        body: {
          'destinataire_id': widget.otherUser['id'],
          'contenu': text
        }
      );

      if (response.statusCode == 201) {
        _fetchMessages();
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: NexaColors.darkNavy,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: NexaColors.primaryGreen.withOpacity(0.1),
              child: Text(widget.otherUser['nom_complet']?[0] ?? '?', style: const TextStyle(color: NexaColors.primaryGreen)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.otherUser['nom_complet'] ?? 'Utilisateur', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(widget.otherUser['role'] ?? 'Membre', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.videocam_outlined)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.info_outline)),
        ],
      ),
      body: Column(
        children: [
          _buildSecurityNotice(),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isMe = msg['expediteur_id'] == widget.userData?['id'];
                    return _buildMessageBubble(msg, isMe);
                  },
                ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildSecurityNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: const Color(0xFFFFF7ED),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, size: 14, color: Colors.orange),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Messagerie sécurisée NexaMa. Le partage direct d\'emails est restreint durant la phase initiale.',
              style: TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(dynamic msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isMe ? NexaColors.primaryGreen : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg['contenu'] ?? '',
              style: TextStyle(color: isMe ? Colors.white : NexaColors.darkNavy, height: 1.4),
            ),
            const SizedBox(height: 4),
            Text(
              '12:45', // Simulation heure
              style: TextStyle(color: (isMe ? Colors.white70 : Colors.grey), fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle_outline, color: Colors.grey)),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _msgController,
                  decoration: const InputDecoration(
                    hintText: 'Écrivez un message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: NexaColors.primaryGreen,
              child: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

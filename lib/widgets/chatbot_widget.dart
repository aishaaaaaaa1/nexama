import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_theme.dart';
import '../config/api_config.dart';

class ChatBotWidget extends StatefulWidget {
  const ChatBotWidget({super.key});

  @override
  State<ChatBotWidget> createState() => _ChatBotWidgetState();
}

class _ChatBotWidgetState extends State<ChatBotWidget> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(
      text: "Bonjour ! 👋 Je suis **NexaBot**, votre assistant intelligent NexaMa. Comment puis-je vous aider aujourd'hui ?",
      isUser: false,
    ));
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      // Construire l'historique pour le backend
      final history = _messages
          .where((m) => _messages.indexOf(m) > 0) // skip le message d'intro
          .map((m) => {'role': m.isUser ? 'user' : 'model', 'text': m.text})
          .toList();

      // Retirer le dernier (c'est le message courant qu'on envoie séparément)
      if (history.isNotEmpty) history.removeLast();

      final response = await http.post(
        ApiConfig.uri('/api/chatbot'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'message': text,
          'history': history,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _messages.add(_ChatMessage(text: data['reply'] ?? 'Pas de réponse', isUser: false));
            _isTyping = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _messages.add(_ChatMessage(text: 'Erreur de connexion au serveur. Réessayez.', isUser: false));
            _isTyping = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(text: 'Impossible de contacter NexaBot. Vérifiez votre connexion.', isUser: false));
          _isTyping = false;
        });
      }
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      height: 520,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: NexaColors.primaryGreen,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NexaBot', style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF4ADE80), shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text('En ligne', style: GoogleFonts.inter(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Posez votre question...',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: _isTyping ? Colors.grey[300] : NexaColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _isTyping ? null : _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 290),
        decoration: BoxDecoration(
          color: msg.isUser ? NexaColors.primaryGreen : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(msg.isUser ? 12 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 12),
          ),
        ),
        child: msg.isUser
            ? Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4))
            : MarkdownBody(
                data: msg.text,
                styleSheet: MarkdownStyleSheet(
                  p: GoogleFonts.inter(fontSize: 13, height: 1.4, color: NexaColors.darkNavy),
                  strong: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: NexaColors.darkNavy),
                  listBullet: const TextStyle(color: NexaColors.primaryGreen, fontSize: 13),
                ),
              ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: NexaColors.primaryGreen.withValues(alpha: value),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}

/// Helper function to show the chatbot as a dialog overlay
void showChatBot(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.black26,
    builder: (context) => Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 24, bottom: 90),
        child: Material(
          color: Colors.transparent,
          child: const ChatBotWidget(),
        ),
      ),
    ),
  );
}

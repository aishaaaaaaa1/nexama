import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';
import './pitch_viewer_page.dart';

class MatchingSwipePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const MatchingSwipePage({super.key, this.userData});

  @override
  State<MatchingSwipePage> createState() => _MatchingSwipePageState();
}

class _MatchingSwipePageState extends State<MatchingSwipePage> {
  List<dynamic> _recommendations = [];
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    try {
      final response = await ApiService.get(ApiConfig.uri('/api/matching/investisseur/recommandations'));
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _recommendations = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSwipe(bool interested) async {
    if (_currentIndex >= _recommendations.length) return;
    
    final project = _recommendations[_currentIndex];
    
    // API call for interest
    if (interested) {
      try {
        await ApiService.post(
          ApiConfig.uri('/api/matching/projets/${project['id']}/interet'),
          body: {'statut': 'INTERESSE'}
        );
      } catch (e) {
        debugPrint('Error marking interest: $e');
      }
    }

    setState(() {
      _currentIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Matching Intelligent', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: NexaColors.darkNavy,
        elevation: 0,
        actions: [
          IconButton(onPressed: _fetchRecommendations, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentIndex >= _recommendations.length
              ? _buildEmptyState()
              : Stack(
                  children: _recommendations.asMap().entries.map((entry) {
                    int idx = entry.key;
                    if (idx < _currentIndex) return const SizedBox.shrink();
                    
                    return _buildSwipeCard(entry.value, idx == _currentIndex);
                  }).toList().reversed.toList(),
                ),
    );
  }

  Widget _buildSwipeCard(dynamic project, bool isTop) {
    return Center(
      child: Draggable(
        axis: Axis.horizontal,
        feedback: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: 350,
            height: 500,
            child: _buildCardContent(project, isDragging: true),
          ),
        ),
        childWhenDragging: const SizedBox.shrink(),
        onDragEnd: (details) {
          if (details.offset.dx > 100) {
            _onSwipe(true); // Right swipe = Interested
          } else if (details.offset.dx < -100) {
            _onSwipe(false); // Left swipe = Pass
          }
        },
        child: SizedBox(
          width: 350,
          height: 500,
          child: _buildCardContent(project),
        ),
      ),
    );
  }

  Widget _buildCardContent(dynamic p, {bool isDragging = false}) {
    final score = p['matching_score'] ?? 0;
    final trust = p['trust_score'] ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Image Placeholder / Visual
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [NexaColors.primaryGreen, NexaColors.darkNavy],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.flash_on, color: Colors.yellow, size: 16),
                        const SizedBox(width: 4),
                        Text('$score%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.rocket_launch, color: Colors.white, size: 64),
                      const SizedBox(height: 12),
                      Text(p['secteur']?.toUpperCase() ?? 'TECH', style: const TextStyle(color: Colors.white70, letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(p['nom'] ?? 'Projet sans nom', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: NexaColors.darkNavy))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            const Icon(Icons.verified, color: NexaColors.primaryGreen, size: 16),
                            const SizedBox(width: 4),
                            Text('$trust', style: const TextStyle(color: NexaColors.primaryGreen, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(p['ville'] ?? 'Maroc', style: const TextStyle(color: Colors.grey)),
                      const SizedBox(width: 16),
                      const Icon(Icons.stairs, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(p['stade_evolution'] ?? 'Idée', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(p['description'] ?? 'Pas de description.', style: const TextStyle(color: Color(0xFF64748B), height: 1.5), maxLines: 3, overflow: TextOverflow.ellipsis),
                  const Spacer(),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('BUDGET RECHERCHÉ', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
                          Text('${p['budget_recherche'] ?? 0} MAD', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: NexaColors.darkNavy)),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PitchViewerPage(projet: p))),
                        icon: const Icon(Icons.info_outline, color: NexaColors.primaryGreen),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _onSwipe(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Passer', style: TextStyle(color: Color(0xFF64748B))),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _onSwipe(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NexaColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Intéressé', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 80, color: NexaColors.primaryGreen),
          const SizedBox(height: 24),
          Text('Plus aucun projet !', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Revenez plus tard pour de nouveaux matchings.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              await ApiService.post(ApiConfig.uri('/api/auth/debug/fix-profile'), body: {});
              setState(() { _currentIndex = 0; _isLoading = true; });
              _fetchRecommendations();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            child: const Text('Réparer mon profil & Actualiser'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentIndex = 0;
                _isLoading = true;
              });
              _fetchRecommendations();
            },
            child: const Text('Actualiser'),
          ),
        ],
      ),
    );
  }
}

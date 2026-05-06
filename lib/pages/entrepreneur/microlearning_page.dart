import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'course_player_page.dart';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';

class MicrolearningPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const MicrolearningPage({super.key, this.userData});

  @override
  State<MicrolearningPage> createState() => _MicrolearningPageState();
}

class _MicrolearningPageState extends State<MicrolearningPage> {
  List<dynamic> _courses = [];
  bool _isLoading = true;
  String _selectedCategory = 'Toutes';
  final List<String> _categories = ['Toutes', 'Fiscalité', 'Marketing', 'Juridique', 'Financement'];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    try {
      final categoryFilter = _selectedCategory == 'Toutes' ? '' : '?categorie=$_selectedCategory';
      final res = await ApiService.get(ApiConfig.uri('/api/courses$categoryFilter'));
      if (res.statusCode == 200) {
        setState(() {
          _courses = json.decode(res.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Load courses error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        _buildCategoryFilters(),
        const SizedBox(height: 32),
        _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Expanded(child: _buildCourseGrid()),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Microlearning pour Entrepreneurs', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
        const SizedBox(height: 8),
        const Text('Formations courtes et pratiques adaptées au marché marocain.', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
      ],
    );
  }

  Widget _buildCategoryFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (val) {
                if (val) {
                  setState(() => _selectedCategory = cat);
                  _loadCourses();
                }
              },
              selectedColor: NexaColors.primaryGreen.withOpacity(0.2),
              labelStyle: TextStyle(color: isSelected ? NexaColors.primaryGreen : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCourseGrid() {
    if (_courses.isEmpty) return const Center(child: Text('Aucun cours disponible dans cette catégorie.'));

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 24, mainAxisSpacing: 24, childAspectRatio: 0.8),
      itemCount: _courses.length,
      itemBuilder: (context, i) => _buildCourseCard(_courses[i]),
    );
  }

  Widget _buildCourseCard(dynamic course) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFE2E8F0))),
      child: InkWell(
        onTap: () => _openCourseDetail(course),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 140,
                width: double.infinity,
                color: NexaColors.primaryGreen.withOpacity(0.1),
                child: Center(child: Icon(Icons.school, size: 48, color: NexaColors.primaryGreen)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: NexaColors.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(course['categorie'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: NexaColors.primaryGreen)),
                  ),
                  const SizedBox(height: 12),
                  Text(course['titre'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text('Par ${course['formateur']['nom_complet']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [const Icon(Icons.access_time, size: 14, color: Colors.grey), const SizedBox(width: 4), Text('${course['duree_totale']} min', style: const TextStyle(fontSize: 12, color: Colors.grey))]),
                      Text('${course['prix']} MAD', style: const TextStyle(fontWeight: FontWeight.bold, color: NexaColors.primaryGreen)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCourseDetail(dynamic course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CoursePlayerPage(courseId: course['id'], userData: widget.userData),
      ),
    );
  }
}

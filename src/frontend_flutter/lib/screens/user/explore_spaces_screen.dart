import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/space_model.dart';
import '../../services/api_service.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/app_page_scroll_view.dart';
import '../../widgets/space_card.dart';

class ExploreSpacesScreen extends StatefulWidget {
  const ExploreSpacesScreen({super.key});

  @override
  State<ExploreSpacesScreen> createState() => _ExploreSpacesScreenState();
}

class _ExploreSpacesScreenState extends State<ExploreSpacesScreen> {
  List<SpaceModel> _spaces = [];
  bool _isLoading = true;
  String _selectedCategory = 'Todos';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final List<String> categories = [
    'Todos',
    'Laboratorio',
  ];

  @override
  void initState() {
    super.initState();
    _loadSpaces();
  }

  Future<void> _loadSpaces() async {
    setState(() => _isLoading = true);
    final spaces = await ApiService.fetchLaboratorios();
    if (!mounted) return;
    setState(() {
      _spaces = spaces;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSpaces = _spaces.where((s) {
      final matchesCategory = _selectedCategory == 'Todos' || s.type == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.resources.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return AppLayout(
      currentRoute: '/user/spaces',
      title: 'Explorar Espacios Universitarios',
      subtitle: 'Consulta de laboratorios y salas en el campus UCEVA',
      mobilePageOwnsScroll: true,
      child: RefreshIndicator(
        onRefresh: _loadSpaces,
        child: AppPageScrollView(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Buscador
                    TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre o ubicación...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filtros
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: isSelected,
                              selectedColor: AppColors.accentGreen,
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textBody,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected ? AppColors.accentGreen : AppColors.surfaceBorder,
                                ),
                              ),
                              onSelected: (val) {
                                setState(() => _selectedCategory = cat);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Mostrando ${filteredSpaces.length} espacio(s)',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 16),

                    if (filteredSpaces.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
                            SizedBox(height: 12),
                            Text(
                              'No se encontraron espacios disponibles',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textStrong),
                            ),
                            SizedBox(height: 4),
                            Text('Verifica que existan laboratorios registrados en la base de datos.', style: TextStyle(color: AppColors.textMuted)),
                          ],
                        ),
                      )
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 520 ? 2 : 1);
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              mainAxisExtent: 250,
                            ),
                            itemCount: filteredSpaces.length,
                            itemBuilder: (context, index) {
                              final sp = filteredSpaces[index];
                              return SpaceCard(
                                space: sp,
                                onDetails: () {
                                  Navigator.pushNamed(context, '/user/space-detail', arguments: sp);
                                },
                                onReserve: () {
                                  Navigator.pushReplacementNamed(context, '/user/wizard', arguments: sp);
                                },
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}

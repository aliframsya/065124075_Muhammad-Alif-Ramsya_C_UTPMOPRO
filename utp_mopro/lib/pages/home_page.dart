import 'package:flutter/material.dart';
import '../models/coffee.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onFavoritesChanged;

  const HomePage({super.key, this.onFavoritesChanged});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Coffee> _coffees = [];
  List<Coffee> _filteredCoffees = [];
  bool _isLoading = true;
  String _selectedFilter = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = ['Semua', 'Light', 'Medium', 'Dark'];

  @override
  void initState() {
    super.initState();
    _loadCoffees();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCoffees() async {
    setState(() => _isLoading = true);
    try {
      final coffees = await DatabaseHelper.instance.getAllCoffees();
      if (mounted) {
        setState(() {
          _coffees = coffees;
          _applyFilter();
        });
      }
    } catch (e) {
      debugPrint('Error load coffees: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> refreshData() async {
    await _loadCoffees();
  }

  void _applyFilter() {
    if (_selectedFilter == 'Semua') {
      _filteredCoffees = List.from(_coffees);
    } else {
      _filteredCoffees =
          _coffees.where((c) => c.roastLevel == _selectedFilter).toList();
    }
  }

  void _searchCoffees(String query) async {
    if (query.isEmpty) {
      _applyFilter();
      setState(() {});
      return;
    }
    final results = await DatabaseHelper.instance.searchCoffees(query);
    setState(() {
      _filteredCoffees = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildFilterChips()),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.espresso),
                ),
              )
            else if (_filteredCoffees.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildCoffeeCard(_filteredCoffees[index]),
                    childCount: _filteredCoffees.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.espresso,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.coffee, color: AppTheme.caramel, size: 26),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kopi Nusantara',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  Text(
                    'Jelajahi Cita Rasa Kopi Pilihan',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppTheme.lightRoast,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: AppTheme.caramel,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: TextField(
        controller: _searchController,
        onChanged: _searchCoffees,
        decoration: InputDecoration(
          hintText: 'Cari kopi, daerah asal, atau cita rasa...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.lightRoast),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear, color: AppTheme.lightRoast),
                    onPressed: () {
                      _searchController.clear();
                      _searchCoffees('');
                    },
                  )
                  : null,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (filter != 'Semua') ...[
                          Icon(
                            RoastLevelHelper.getIcon(filter),
                            size: 14,
                            color:
                                isSelected
                                    ? Colors.white
                                    : RoastLevelHelper.getColor(filter),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          filter == 'Semua' ? '☕ Semua' : filter,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                            color:
                                isSelected
                                    ? Colors.white
                                    : AppTheme.mediumRoast,
                          ),
                        ),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                        _searchController.clear();
                        _applyFilter();
                      });
                    },
                    selectedColor: AppTheme.espresso,
                    backgroundColor: AppTheme.cream,
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildCoffeeCard(Coffee coffee) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(coffeeId: coffee.id!),
          ),
        );
        await _loadCoffees();
        widget.onFavoritesChanged?.call();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppTheme.espresso.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Gambar Kopi (Asset / Network)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CoffeeImageView(
                  imageUrl: coffee.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              // Informasi Kopi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            coffee.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (coffee.isFavorite)
                          const Icon(
                            Icons.favorite,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppTheme.lightRoast,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            coffee.origin,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: RoastLevelHelper.getColor(
                              coffee.roastLevel,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                RoastLevelHelper.getIcon(coffee.roastLevel),
                                size: 12,
                                color: RoastLevelHelper.getColor(
                                  coffee.roastLevel,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${coffee.roastLevel} Roast',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: RoastLevelHelper.getColor(
                                    coffee.roastLevel,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 17,
                              color: AppTheme.gold,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              coffee.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.espresso,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (coffee.personalNote != null &&
                        coffee.personalNote!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.cream,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.caramel.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.sticky_note_2_outlined,
                              size: 13,
                              color: AppTheme.caramel,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                coffee.personalNote!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: AppTheme.mediumRoast,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.lightRoast,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, size: 48, color: AppTheme.lightRoast),
          const SizedBox(height: 12),
          Text(
            'Kopi tidak ditemukan',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Coba kata kunci lain',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/coffee.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import 'detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => FavoritesPageState();
}

class FavoritesPageState extends State<FavoritesPage> {
  List<Coffee> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final favorites = await DatabaseHelper.instance.getFavoriteCoffees();
    setState(() {
      _favorites = favorites;
      _isLoading = false;
    });
  }

  Future<void> refreshData() async {
    await _loadFavorites();
  }

  Future<void> _removeFavorite(Coffee coffee) async {
    if (coffee.id == null) return;
    await DatabaseHelper.instance.toggleFavorite(coffee.id!, false);
    await _loadFavorites();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${coffee.name} dihapus dari favorit'),
          backgroundColor: AppTheme.espresso,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'Batal',
            textColor: AppTheme.caramel,
            onPressed: () async {
              await DatabaseHelper.instance.toggleFavorite(coffee.id!, true);
              await _loadFavorites();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.favorite, color: Colors.redAccent, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kopi Favoritku',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          Text(
                            '${_favorites.length} kopi tersimpan di SQLite',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
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
                      color: Colors.redAccent.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.espresso,
                        ),
                      )
                      : _favorites.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _favorites.length,
                        itemBuilder: (context, index) {
                          return _buildFavoriteCard(_favorites[index]);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(Coffee coffee) {
    return Dismissible(
      key: Key('fav_${coffee.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.redAccent),
            SizedBox(height: 2),
            Text(
              'Hapus',
              style: TextStyle(fontSize: 11, color: Colors.redAccent),
            ),
          ],
        ),
      ),
      onDismissed: (_) => _removeFavorite(coffee),
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPage(coffeeId: coffee.id!),
            ),
          );
          await _loadFavorites();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.espresso.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.redAccent.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CoffeeImageView(
                      imageUrl: coffee.imageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coffee.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      coffee.origin,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (coffee.personalNote != null &&
                        coffee.personalNote!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.caramel.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.sticky_note_2_outlined,
                              size: 12,
                              color: AppTheme.caramel,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                coffee.personalNote!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.mediumRoast,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 16,
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
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.lightRoast,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.cream,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                color: AppTheme.lightRoast,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Belum Ada Favorit',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Jelajahi katalog dan tap ❤️ pada kopi\nyang kamu suka untuk menyimpannya di sini.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightRoast,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/coffee.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';

class DetailPage extends StatefulWidget {
  final int coffeeId;

  const DetailPage({super.key, required this.coffeeId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Coffee? _coffee;
  bool _isLoading = true;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCoffee();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadCoffee() async {
    final coffee = await DatabaseHelper.instance.getCoffeeById(widget.coffeeId);
    setState(() {
      _coffee = coffee;
      _noteController.text = coffee?.personalNote ?? '';
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    if (_coffee == null || _coffee!.id == null) return;
    final newStatus = !_coffee!.isFavorite;
    await DatabaseHelper.instance.toggleFavorite(_coffee!.id!, newStatus);
    setState(() {
      _coffee = _coffee!.copyWith(isFavorite: newStatus);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus
                ? '❤️ ${_coffee!.name} ditambahkan ke favorit'
                : '${_coffee!.name} dihapus dari favorit',
          ),
          backgroundColor: AppTheme.espresso,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveNote() async {
    if (_coffee == null || _coffee!.id == null) return;
    final note = _noteController.text.trim();
    await DatabaseHelper.instance.updatePersonalNote(
      _coffee!.id!,
      note.isEmpty ? null : note,
    );
    setState(() {
      _coffee = _coffee!.copyWith(personalNote: note.isEmpty ? null : note);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('📝 Catatan disimpan ke SQLite!'),
          backgroundColor: AppTheme.espresso,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.espresso),
        ),
      );
    }

    if (_coffee == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Kopi tidak ditemukan')),
      );
    }

    final coffee = _coffee!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Banner Gambar Kopi Asli
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.espresso,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: IconButton(
                    icon: Icon(
                      coffee.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                          coffee.isFavorite
                              ? Colors.redAccent
                              : Colors.white,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CoffeeImageView(
                    imageUrl: coffee.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.5),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.85),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coffee.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(blurRadius: 10, color: Colors.black87),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: AppTheme.caramel,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              coffee.origin,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                shadows: [
                                  Shadow(blurRadius: 8, color: Colors.black87),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoPills(coffee),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Tentang Kopi Ini'),
                  const SizedBox(height: 8),
                  Text(
                    coffee.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Profil Rasa'),
                  const SizedBox(height: 10),
                  _buildFlavorNotes(coffee),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Rekomendasi Penyeduhan'),
                  const SizedBox(height: 10),
                  _buildBrewMethod(coffee),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Catatan Pribadi (Disimpan di SQLite)'),
                  const SizedBox(height: 10),
                  _buildPersonalNote(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPills(Coffee coffee) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        _infoPill(
          icon: RoastLevelHelper.getIcon(coffee.roastLevel),
          label: '${coffee.roastLevel} Roast',
          color: RoastLevelHelper.getColor(coffee.roastLevel),
        ),
        _infoPill(
          icon: Icons.star_rounded,
          label: '${coffee.rating.toStringAsFixed(1)} / 5.0',
          color: AppTheme.gold,
        ),
        if (coffee.isFavorite)
          _infoPill(
            icon: Icons.favorite,
            label: 'Favorit',
            color: Colors.redAccent,
          ),
      ],
    );
  }

  Widget _infoPill({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppTheme.caramel,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }

  Widget _buildFlavorNotes(Coffee coffee) {
    final notes = coffee.flavorNotes.split(', ');
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          notes.map((note) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.cream,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.caramel.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bubble_chart_outlined, size: 16, color: AppTheme.mediumRoast),
                  const SizedBox(width: 6),
                  Text(
                    note.trim(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.espresso,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildBrewMethod(Coffee coffee) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.caramel.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.espresso,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.coffee_maker_rounded,
              color: AppTheme.caramel,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Metode Terbaik',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  coffee.brewMethod,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalNote() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cream),
        boxShadow: [
          BoxShadow(
            color: AppTheme.espresso.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _noteController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'Tulis pengalamanmu mencicipi kopi ini...\n'
                  'Misal: "Enak diminum sore hari, cocok dengan pisang goreng"',
              border: InputBorder.none,
              filled: false,
              contentPadding: const EdgeInsets.all(16),
              hintStyle: TextStyle(
                fontSize: 13,
                color: AppTheme.lightRoast.withValues(alpha: 0.6),
              ),
            ),
            style: const TextStyle(fontSize: 14, color: AppTheme.espresso),
          ),
          const Divider(height: 1, color: AppTheme.cream),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_coffee?.personalNote != null &&
                    _coffee!.personalNote!.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      _noteController.clear();
                      _saveNote();
                    },
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Hapus', style: TextStyle(fontSize: 13)),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _saveNote,
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: const Text(
                    'Simpan Catatan',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.espresso,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

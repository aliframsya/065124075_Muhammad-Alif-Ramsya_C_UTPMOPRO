import 'package:flutter/material.dart';
import '../models/coffee.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import 'detail_page.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => NotesPageState();
}

class NotesPageState extends State<NotesPage> {
  List<Coffee> _notedCoffees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    final coffees = await DatabaseHelper.instance.getCoffeesWithNotes();
    if (mounted) {
      setState(() {
        _notedCoffees = coffees;
        _isLoading = false;
      });
    }
  }

  Future<void> refreshData() async {
    await _loadNotes();
  }

  Future<void> _deleteNote(Coffee coffee) async {
    if (coffee.id == null) return;
    await DatabaseHelper.instance.updatePersonalNote(coffee.id!, null);
    await _loadNotes();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catatan untuk ${coffee.name} dihapus'),
          backgroundColor: AppTheme.espresso,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'Batal',
            textColor: AppTheme.caramel,
            onPressed: () async {
              await DatabaseHelper.instance.updatePersonalNote(
                coffee.id!,
                coffee.personalNote,
              );
              await _loadNotes();
            },
          ),
        ),
      );
    }
  }

  void _showEditNoteDialog(Coffee coffee) {
    final controller = TextEditingController(text: coffee.personalNote ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.edit_note_rounded, color: AppTheme.espresso),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Edit Catatan: ${coffee.name}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.espresso,
                ),
              ),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Tuliskan kesan rasa kopi ini...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.caramel.withValues(alpha: 0.3)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppTheme.lightRoast)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newNote = controller.text.trim();
              await DatabaseHelper.instance.updatePersonalNote(
                coffee.id!,
                newNote.isEmpty ? null : newNote,
              );
              if (ctx.mounted) Navigator.pop(ctx);
              await _loadNotes();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.espresso,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                          color: AppTheme.caramel.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.sticky_note_2_rounded,
                          color: AppTheme.espresso,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jurnal Catatan Kopi',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          Text(
                            '${_notedCoffees.length} kopi memiliki catatan pribadi',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.espresso),
                    )
                  : _notedCoffees.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _notedCoffees.length,
                          itemBuilder: (context, index) {
                            return _buildNoteCard(_notedCoffees[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(Coffee coffee) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.espresso.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppTheme.caramel.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info kopi
          InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailPage(coffeeId: coffee.id!),
                ),
              );
              await _loadNotes();
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CoffeeImageView(
                      imageUrl: coffee.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coffee.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.espresso,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: AppTheme.lightRoast,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              coffee.origin,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.lightRoast,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppTheme.lightRoast,
                  ),
                ],
              ),
            ),
          ),

          // Kotak Catatan Pribadi (Widget Sticky Note)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.caramel.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.format_quote_rounded,
                      size: 18,
                      color: AppTheme.caramel,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Catatan Review:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.mediumRoast,
                      ),
                    ),
                    const Spacer(),
                    // Tombol Edit
                    InkWell(
                      onTap: () => _showEditNoteDialog(coffee),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: AppTheme.espresso,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Tombol Hapus
                    InkWell(
                      onTap: () => _deleteNote(coffee),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 16,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  coffee.personalNote ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.espresso,
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
                Icons.note_alt_outlined,
                color: AppTheme.lightRoast,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Belum Ada Catatan Kopi',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Buka detail salah satu kopi di katalog, lalu tuliskan pengalaman rasamu di kolom "Catatan Pribadi" untuk menyimpannya di sini.',
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

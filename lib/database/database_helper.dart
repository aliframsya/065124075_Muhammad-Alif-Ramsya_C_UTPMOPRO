import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/coffee.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  bool _useFallback = false;

  DatabaseHelper._init();

  static void ensureInitialized() {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  // Koleksi Kopi Nusantara dengan foto asli satu cangkir/gelas kopi yang jelas & fokus (close-up)
  static final List<Map<String, dynamic>> initialSeedData = [
    {
      'id': 1,
      'name': 'Kopi Sidikalang',
      'origin': 'Dairi, Sumatera Utara',
      'roastLevel': 'Dark',
      'description':
          'Kopi legendaris dari dataran tinggi Dairi di ketinggian 1.500 mdpl yang dijuluki sebagai "Rajanya Kopi Sumatera". Disajikan dalam satu cangkir kopi hitam pekat dengan tekstur halus, aftertaste cokelat hitam tebal tanpa rasa asam berlebih, dan aroma khas yang sangat memikat.',
      'flavorNotes': 'Dark Chocolate, Spicy, Sweet Earthy',
      'rating': 4.9,
      'imageUrl':
          'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=600&auto=format&fit=crop&q=80',
      'brewMethod': 'Tubruk / French Press',
      'isFavorite': 0,
      'personalNote': null,
    },
    {
      'id': 2,
      'name': 'Kopi Gayo',
      'origin': 'Aceh, Sumatera',
      'roastLevel': 'Medium',
      'description':
          'Kopi arabika dataran tinggi Gayo Aceh dalam cangkir kopi hitam mengepul. Memiliki aroma rempah herbal khas Aceh, tingkat keasaman seimbang, dan aftertaste manis cokelat yang tahan lama.',
      'flavorNotes': 'Cokelat, Rempah, Herbal',
      'rating': 4.8,
      'imageUrl':
          'https://images.unsplash.com/photo-1507133750040-4a8f57021571?w=600&auto=format&fit=crop&q=80',
      'brewMethod': 'Saring Aceh / V60',
      'isFavorite': 0,
      'personalNote': null,
    },
    {
      'id': 3,
      'name': 'Kopi Toraja',
      'origin': 'Sulawesi Selatan',
      'roastLevel': 'Dark',
      'description':
          'Kopi legendaris pegunungan Tana Toraja di cangkir keramik hangat. Proses giling basah tradisional menghasilkan rasa earthy yang khas, aroma kacang walnut gurih, dan body yang sangat tebal.',
      'flavorNotes': 'Earthy, Dark Chocolate, Walnut',
      'rating': 4.7,
      'imageUrl':
          'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?w=600&auto=format&fit=crop&q=80',
      'brewMethod': 'French Press / Tubruk',
      'isFavorite': 0,
      'personalNote': null,
    },
    {
      'id': 4,
      'name': 'Kopi Kintamani',
      'origin': 'Bali',
      'roastLevel': 'Light',
      'description':
          'Kopi arabika Kintamani di gelas seduh transparan. Tumbuh berdampingan dengan kebun jeruk Bali, memberikan cita rasa asam citrus buah segar yang cerah dan aftertaste floral yang bersih.',
      'flavorNotes': 'Citrus, Floral, Madu',
      'rating': 4.6,
      'imageUrl':
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=600&auto=format&fit=crop&q=80',
      'brewMethod': 'Chemex / Pour Over',
      'isFavorite': 0,
      'personalNote': null,
    },
    {
      'id': 5,
      'name': 'Kopi Luwak',
      'origin': 'Jawa Timur',
      'roastLevel': 'Medium',
      'description':
          'Kopi eksklusif langka dunia dalam cangkir porselen putih elegan dengan lapisan golden crema. Fermentasi alami di pencernaan luwak menghasilkan kopi dengan kadar keasaman sangat rendah dan tekstur luar biasa lembut.',
      'flavorNotes': 'Caramel, Smooth, Nutty',
      'rating': 4.9,
      'imageUrl':
          'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=600&auto=format&fit=crop&q=80',
      'brewMethod': 'Syphon / Aeropress',
      'isFavorite': 0,
      'personalNote': null,
    },
    {
      'id': 6,
      'name': 'Kopi Wamena',
      'origin': 'Papua',
      'roastLevel': 'Light',
      'description':
          'Kopi murni organik dari Lembah Baliem Papua dalam satu gelas seduh hitam segar. Tumbuh liar di ketinggian 1.600 mdpl tanpa pestisida dengan karakter rasa buah beri manis seperti teh herbal pegunungan.',
      'flavorNotes': 'Berry, Floral, Tea-like',
      'rating': 4.5,
      'imageUrl':
          'https://images.unsplash.com/photo-1518832553480-cd0e625ed3e6?w=600&auto=format&fit=crop&q=80',
      'brewMethod': 'AeroPress / V60',
      'isFavorite': 0,
      'personalNote': null,
    },
    {
      'id': 7,
      'name': 'Kopi Flores Bajawa',
      'origin': 'Nusa Tenggara Timur',
      'roastLevel': 'Medium',
      'description':
          'Seduhan kopi hangat di cangkir Bajawa Flores. Ditanam di tanah vulkanik Gunung Inerie dengan aroma tembakau manis alami, cokelat gurih, dan sentuhan karamel yang memikat.',
      'flavorNotes': 'Cokelat, Tembakau, Spicy',
      'rating': 4.6,
      'imageUrl':
          'https://images.unsplash.com/photo-1497636577773-f1231844b336?w=600&auto=format&fit=crop&q=80',
      'brewMethod': 'Tubruk / V60',
      'isFavorite': 0,
      'personalNote': null,
    },
    {
      'id': 8,
      'name': 'Kopi Mandailing',
      'origin': 'Sumatera Utara',
      'roastLevel': 'Dark',
      'description':
          'Kopi hitam pekat dalam mug keramik tebal. Cita rasa kuat khas Sumatera Utara dengan body tebal, aroma kayu cedar, dan kepahitan nikmat yang dicari para pecinta kopi tulen.',
      'flavorNotes': 'Bold, Earthy, Cedar',
      'rating': 4.4,
      'imageUrl':
          'https://images.unsplash.com/photo-1521302080334-4bebac2763a6?w=600&auto=format&fit=crop&q=80',
      'brewMethod': 'Espresso / Moka Pot',
      'isFavorite': 0,
      'personalNote': null,
    },
    {
      'id': 9,
      'name': 'Kopi Java Preanger',
      'origin': 'Jawa Barat',
      'roastLevel': 'Medium',
      'description':
          'Sajian satu cangkir kopi klasik Priangan. Kopi kebanggaan Tatar Sunda dengan aroma manis seimbang, sentuhan buah tropis, dan karakter lembut yang melegenda sejak era kolonial.',
      'flavorNotes': 'Nutty, Sweet, Mild',
      'rating': 4.5,
      'imageUrl':
          'https://images.unsplash.com/photo-1511920170033-f8396924c348?w=600&auto=format&fit=crop&q=80',
      'brewMethod': 'Drip / Pour Over',
      'isFavorite': 0,
      'personalNote': null,
    },
    {
      'id': 10,
      'name': 'Kopi Temanggung',
      'origin': 'Jawa Tengah',
      'roastLevel': 'Dark',
      'description':
          'Kopi robusta juara dari lereng Sindoro-Sumbing dalam cangkir seduh hitam pekat. Memiliki aroma smoky yang harum, aftertaste molase tebal, dan rasa cokelat pekat tanpa asam.',
      'flavorNotes': 'Cokelat Hitam, Smoky, Molasses',
      'rating': 4.3,
      'imageUrl':
          'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=600&auto=format&fit=crop&q=80',
      'brewMethod': 'Vietnam Drip / Tubruk',
      'isFavorite': 0,
      'personalNote': null,
    },
    {
      'id': 11,
      'name': 'Kopi Semendo',
      'origin': 'Sumatera Selatan',
      'roastLevel': 'Medium',
      'description':
          'Robusta khas dataran tinggi Semendo disajikan dalam gelas kopi tubruk tradisional. Aroma rempah hangat berpadu dengan body tebal dan rasa manis gula aren alami yang nikmat.',
      'flavorNotes': 'Dark Choco, Spice, Full Body',
      'rating': 4.4,
      'imageUrl':
          'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=600&auto=format&fit=crop&q=80',
      'brewMethod': 'Tubruk / French Press',
      'isFavorite': 0,
      'personalNote': null,
    },
  ];

  // In-memory fallback cache
  late final List<Coffee> _fallbackList =
      initialSeedData.map((m) => Coffee.fromMap(m)).toList();

  Future<Database?> get database async {
    if (_useFallback) return null;
    if (_database != null) return _database!;
    if (kIsWeb) {
      _useFallback = true;
      return null;
    }
    try {
      ensureInitialized();
      _database = await _initDB('kopi_nusantara.db');
      return _database!;
    } catch (e) {
      debugPrint('SQLite initialization fallback: $e');
      _useFallback = true;
      return null;
    }
  }

  Future<Database> _initDB(String filePath) async {
    ensureInitialized();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 6,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS coffees');
        await _createDB(db, newVersion);
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE coffees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        origin TEXT NOT NULL,
        roastLevel TEXT NOT NULL,
        description TEXT NOT NULL,
        flavorNotes TEXT NOT NULL,
        rating REAL NOT NULL,
        imageUrl TEXT NOT NULL,
        brewMethod TEXT NOT NULL,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        personalNote TEXT
      )
    ''');

    for (final data in initialSeedData) {
      await db.insert('coffees', data);
    }
  }

  // ==================== CRUD Operations (SQLite) ====================

  Future<List<Coffee>> getAllCoffees() async {
    try {
      final db = await database;
      if (db != null) {
        final result = await db.query('coffees', orderBy: 'id ASC');
        if (result.isNotEmpty) {
          return result.map((map) => Coffee.fromMap(map)).toList();
        }
      }
    } catch (e) {
      debugPrint('Error query SQLite: $e');
    }
    return List.from(_fallbackList);
  }

  Future<Coffee?> getCoffeeById(int id) async {
    try {
      final db = await database;
      if (db != null) {
        final result =
            await db.query('coffees', where: 'id = ?', whereArgs: [id]);
        if (result.isNotEmpty) {
          return Coffee.fromMap(result.first);
        }
      }
    } catch (e) {
      debugPrint('Error getCoffeeById SQLite: $e');
    }
    try {
      return _fallbackList.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Coffee>> getFavoriteCoffees() async {
    try {
      final db = await database;
      if (db != null) {
        final result = await db.query(
          'coffees',
          where: 'isFavorite = ?',
          whereArgs: [1],
          orderBy: 'id ASC',
        );
        return result.map((map) => Coffee.fromMap(map)).toList();
      }
    } catch (e) {
      debugPrint('Error getFavoriteCoffees SQLite: $e');
    }
    return _fallbackList.where((c) => c.isFavorite).toList();
  }

  Future<int> toggleFavorite(int id, bool isFavorite) async {
    for (final c in _fallbackList) {
      if (c.id == id) {
        c.isFavorite = isFavorite;
        break;
      }
    }
    try {
      final db = await database;
      if (db != null) {
        return await db.update(
          'coffees',
          {'isFavorite': isFavorite ? 1 : 0},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    } catch (e) {
      debugPrint('Error toggleFavorite SQLite: $e');
    }
    return 1;
  }

  Future<int> updatePersonalNote(int id, String? note) async {
    for (final c in _fallbackList) {
      if (c.id == id) {
        c.personalNote = note;
        break;
      }
    }
    try {
      final db = await database;
      if (db != null) {
        return await db.update(
          'coffees',
          {'personalNote': note},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    } catch (e) {
      debugPrint('Error updatePersonalNote SQLite: $e');
    }
    return 1;
  }

  Future<List<Coffee>> searchCoffees(String query) async {
    try {
      final db = await database;
      if (db != null) {
        final result = await db.query(
          'coffees',
          where: 'name LIKE ? OR origin LIKE ? OR flavorNotes LIKE ?',
          whereArgs: ['%$query%', '%$query%', '%$query%'],
          orderBy: 'id ASC',
        );
        return result.map((map) => Coffee.fromMap(map)).toList();
      }
    } catch (e) {
      debugPrint('Error searchCoffees SQLite: $e');
    }
    final q = query.toLowerCase();
    return _fallbackList.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.origin.toLowerCase().contains(q) ||
          c.flavorNotes.toLowerCase().contains(q);
    }).toList();
  }

  Future close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

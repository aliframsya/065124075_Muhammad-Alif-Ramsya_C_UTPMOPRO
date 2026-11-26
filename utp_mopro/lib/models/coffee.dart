import 'dart:convert';

class Coffee {
  final int? id;
  final String name;
  final String origin;
  final String roastLevel;
  final String description;
  final String flavorNotes;
  final double rating;
  final String imageUrl;
  final String brewMethod;
  bool isFavorite;
  String? personalNote;

  Coffee({
    this.id,
    required this.name,
    required this.origin,
    required this.roastLevel,
    required this.description,
    required this.flavorNotes,
    required this.rating,
    required this.imageUrl,
    required this.brewMethod,
    this.isFavorite = false,
    this.personalNote,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'origin': origin,
      'roastLevel': roastLevel,
      'description': description,
      'flavorNotes': flavorNotes,
      'rating': rating,
      'imageUrl': imageUrl,
      'brewMethod': brewMethod,
      'isFavorite': isFavorite ? 1 : 0,
      'personalNote': personalNote,
    };
  }

  factory Coffee.fromMap(Map<String, dynamic> map) {
    return Coffee(
      id: map['id'] as int?,
      name: map['name'] as String,
      origin: map['origin'] as String,
      roastLevel: map['roastLevel'] as String,
      description: map['description'] as String,
      flavorNotes: map['flavorNotes'] as String,
      rating: (map['rating'] as num).toDouble(),
      imageUrl: (map['imageUrl'] as String?) ??
          'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=600&auto=format&fit=crop&q=80',
      brewMethod: map['brewMethod'] as String,
      isFavorite: (map['isFavorite'] as int) == 1,
      personalNote: map['personalNote'] as String?,
    );
  }

  // --- JSON Serialization & Deserialization ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'origin': origin,
      'roastLevel': roastLevel,
      'description': description,
      'flavorNotes': flavorNotes,
      'rating': rating,
      'imageUrl': imageUrl,
      'brewMethod': brewMethod,
      'isFavorite': isFavorite,
      'personalNote': personalNote,
    };
  }

  factory Coffee.fromJson(Map<String, dynamic> json) {
    return Coffee(
      id: json['id'] as int?,
      name: json['name'] as String,
      origin: json['origin'] as String,
      roastLevel: json['roastLevel'] as String,
      description: json['description'] as String,
      flavorNotes: json['flavorNotes'] as String,
      rating: (json['rating'] as num).toDouble(),
      imageUrl: (json['imageUrl'] as String?) ??
          'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=600&auto=format&fit=crop&q=80',
      brewMethod: json['brewMethod'] as String,
      isFavorite: json['isFavorite'] is bool
          ? json['isFavorite'] as bool
          : (json['isFavorite'] as num?) == 1,
      personalNote: json['personalNote'] as String?,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory Coffee.fromJsonString(String source) =>
      Coffee.fromJson(jsonDecode(source) as Map<String, dynamic>);

  Coffee copyWith({
    int? id,
    String? name,
    String? origin,
    String? roastLevel,
    String? description,
    String? flavorNotes,
    double? rating,
    String? imageUrl,
    String? brewMethod,
    bool? isFavorite,
    String? personalNote,
  }) {
    return Coffee(
      id: id ?? this.id,
      name: name ?? this.name,
      origin: origin ?? this.origin,
      roastLevel: roastLevel ?? this.roastLevel,
      description: description ?? this.description,
      flavorNotes: flavorNotes ?? this.flavorNotes,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      brewMethod: brewMethod ?? this.brewMethod,
      isFavorite: isFavorite ?? this.isFavorite,
      personalNote: personalNote ?? this.personalNote,
    );
  }
}

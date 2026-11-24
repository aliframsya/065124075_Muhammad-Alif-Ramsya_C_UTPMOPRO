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

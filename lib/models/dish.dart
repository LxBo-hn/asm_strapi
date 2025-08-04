import 'category.dart';

class Dish {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final Category category;
  final DateTime createdAt;
  final DateTime updatedAt;

  Dish({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    // Handle both direct structure and nested data structure
    Map<String, dynamic> data;
    int id;
    
    if (json.containsKey('data')) {
      // Nested structure: {data: {id: 1, name: "...", ...}}
      final dataValue = json['data'] as Map<String, dynamic>;
      data = dataValue;
    } else {
      // Direct structure: {id: 1, name: "...", ...}
      data = json;
    }
    
    id = data['id'] as int;
    
    // Handle category - it might be populated or just an ID
    Category category;
    if (data['category'] != null && data['category'] is Map<String, dynamic>) {
      category = Category.fromJson(data['category']);
    } else {
      // Create a mock category if not populated
      category = Category(
        id: data['category'] as int? ?? 1,
        name: 'Unknown',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    
    return Dish(
      id: id,
      name: data['name'] as String,
      description: data['description'] as String?,
      price: double.parse(data['price'].toString()),
      imageUrl: _extractImageUrl(data['image']),
      category: category,
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    );
  }

  // Helper method to extract image URL from various Strapi response formats
  static String? _extractImageUrl(dynamic imageData) {
    print('Extracting image URL from: $imageData');
    
    if (imageData == null) {
      print('Image data is null');
      return null;
    }
    
    if (imageData is Map<String, dynamic>) {
      // Handle Strapi v4 format: {url: "...", formats: {...}}
      if (imageData.containsKey('url')) {
        final url = imageData['url'] as String?;
        print('Found URL in image data: $url');
        return url?.replaceAll('localhost', '10.0.2.2');
      }
      
      // Handle nested data structure: {data: {attributes: {url: "..."}}}
      if (imageData.containsKey('data')) {
        final data = imageData['data'];
        if (data is Map<String, dynamic> && data.containsKey('attributes')) {
          final attributes = data['attributes'];
          if (attributes is Map<String, dynamic> && attributes.containsKey('url')) {
            final url = attributes['url'] as String?;
            print('Found URL in nested data: $url');
            return url?.replaceAll('localhost', '10.0.2.2');
          }
        }
      }
    }
    
    print('No valid image URL found in data: $imageData');
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'attributes': {
          'name': name,
          'description': description,
          'price': price,
          'category': category.id,
        }
      }
    };
  }

  Dish copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    Category? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Dish(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 
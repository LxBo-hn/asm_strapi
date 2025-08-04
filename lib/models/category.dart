class Category {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    // Handle various response structures with null safety
    Map<String, dynamic> data;
    int id;
    
    if (json.containsKey('data')) {
      // Nested structure: {data: {id: 1, name: "...", ...}}
      final dataValue = json['data'];
      if (dataValue == null) {
        throw Exception('Category data is null');
      }
      
      if (dataValue is! Map<String, dynamic>) {
        throw Exception('Category data is not a Map: ${dataValue.runtimeType}');
      }
      
      data = dataValue;
    } else {
      // Direct structure: {id: 1, name: "...", ...}
      data = json;
    }
    
    // Extract fields directly from data
    final idValue = data['id'];
    if (idValue == null) {
      throw Exception('Category id is null');
    }
    id = idValue as int;
    
    final name = data['name'];
    if (name == null) {
      throw Exception('Category name is null');
    }
    
    final createdAt = data['createdAt'];
    if (createdAt == null) {
      throw Exception('Category createdAt is null');
    }
    
    final updatedAt = data['updatedAt'];
    if (updatedAt == null) {
      throw Exception('Category updatedAt is null');
    }
    
    return Category(
      id: id,
      name: name as String,
      createdAt: DateTime.parse(createdAt as String),
      updatedAt: DateTime.parse(updatedAt as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'attributes': {
          'name': name,
        }
      }
    };
  }
} 
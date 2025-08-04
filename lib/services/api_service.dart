import 'dart:io';
import 'package:dio/dio.dart';
import '../models/dish.dart';
import '../models/category.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:1337/api'; // For Android emulator
  final Dio _dio = Dio();

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5); // Giảm timeout
    _dio.options.receiveTimeout = const Duration(seconds: 5);
  }

  // Category APIs
  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      
      if (response.data == null) {
        throw Exception('No data received from server');
      }
      
      // Debug: Print the response structure
      print('API Response: ${response.data}');
      
      final data = response.data['data'];
      if (data == null) {
        throw Exception('No categories data found in response. Response: ${response.data}');
      }
      
      if (data is! List) {
        throw Exception('Categories data is not a list. Type: ${data.runtimeType}, Value: $data');
      }
      
      final List<dynamic> categoriesData = data;
      return categoriesData.map((json) {
        print('Processing category JSON: $json');
        return Category.fromJson(json);
      }).toList();
    } catch (e) {
      print('API Error: $e');
      print('Using mock data for development...');
      // Return mock data as fallback for development
      return _getMockCategories();
    }
  }
  
  // Mock data for development/testing
  List<Category> _getMockCategories() {
    return [
      Category(
        id: 1,
        name: 'Appetizers',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Category(
        id: 2,
        name: 'Main Course',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Category(
        id: 3,
        name: 'Desserts',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Category(
        id: 4,
        name: 'Beverages',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  Future<Category> createCategory(String name) async {
    try {
      final response = await _dio.post('/categories', data: {
        'data': {
          'attributes': {
            'name': name,
          }
        }
      });
      return Category.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  // Dish APIs
  Future<List<Dish>> getDishes() async {
    try {
      final response = await _dio.get('/dishes?populate=*');
      
      if (response.data == null) {
        throw Exception('No data received from server');
      }
      
      final data = response.data['data'];
      if (data == null) {
        throw Exception('No dishes data found in response');
      }
      
      final List<dynamic> dishesData = data as List<dynamic>;
      print('Received dishes data: $dishesData');
      return dishesData.map((json) => Dish.fromJson(json)).toList();
    } catch (e) {
      print('API Error: $e');
      print('Using mock data for development...');
      // Return mock data as fallback for development
      return _getMockDishes();
    }
  }
  
  // Mock data for development/testing
  List<Dish> _getMockDishes() {
    final categories = _getMockCategories();
    return [
      Dish(
        id: 1,
        name: 'Bruschetta',
        description: 'Toasted bread topped with tomatoes, garlic, and olive oil',
        price: 8.99,
        category: categories[0], // Appetizers
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Dish(
        id: 2,
        name: 'Grilled Salmon',
        description: 'Fresh salmon grilled to perfection with herbs',
        price: 24.99,
        category: categories[1], // Main Course
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Dish(
        id: 3,
        name: 'Tiramisu',
        description: 'Classic Italian dessert with coffee and mascarpone',
        price: 12.99,
        category: categories[2], // Desserts
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Dish(
        id: 4,
        name: 'Fresh Lemonade',
        description: 'Homemade lemonade with fresh lemons',
        price: 4.99,
        category: categories[3], // Beverages
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  Future<Dish> getDish(int id) async {
    try {
      final response = await _dio.get('/dishes/$id?populate=*');
      return Dish.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to load dish: $e');
    }
  }

  Future<Dish> createDish({
    required String name,
    String? description,
    required double price,
    required int categoryId,
    File? imageFile,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'data': {
          'name': name,
          'description': description,
          'price': price,
          'category': categoryId,
        }
      });

      if (imageFile != null) {
        formData.files.add(MapEntry(
          'files.image',
          await MultipartFile.fromFile(imageFile.path),
        ));
      }

      final response = await _dio.post('/dishes', data: formData);
      return Dish.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create dish: $e');
    }
  }

  Future<Dish> updateDish({
    required int id,
    required String name,
    String? description,
    required double price,
    required int categoryId,
    File? imageFile,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'data': {
          'name': name,
          'description': description,
          'price': price,
          'category': categoryId,
        }
      });

      if (imageFile != null) {
        formData.files.add(MapEntry(
          'files.image',
          await MultipartFile.fromFile(imageFile.path),
        ));
      }

      final response = await _dio.put('/dishes/$id', data: formData);
      return Dish.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update dish: $e');
    }
  }

  Future<void> deleteDish(int id) async {
    try {
      await _dio.delete('/dishes/$id');
    } catch (e) {
      throw Exception('Failed to delete dish: $e');
    }
  }
} 
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/dish.dart';
import '../models/category.dart';
import 'api_service.dart';

class MenuProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Dish> _dishes = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  Category? _selectedCategory;

  // Getters
  List<Dish> get dishes => _dishes;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  Category? get selectedCategory => _selectedCategory;

  // Filtered dishes based on search and category
  List<Dish> get filteredDishes {
    List<Dish> filtered = _dishes;
    
    if (_selectedCategory != null) {
      filtered = filtered.where((dish) => dish.category.id == _selectedCategory!.id).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((dish) => 
        dish.name.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  // Load categories
  Future<void> loadCategories() async {
    _setLoading(true);
    try {
      _categories = await _apiService.getCategories();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Load dishes
  Future<void> loadDishes() async {
    _setLoading(true);
    try {
      _dishes = await _apiService.getDishes();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Create dish
  Future<bool> createDish({
    required String name,
    String? description,
    required double price,
    required int categoryId,
    File? imageFile,
  }) async {
    _setLoading(true);
    try {
      final newDish = await _apiService.createDish(
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        imageFile: imageFile,
      );
      _dishes.add(newDish);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update dish
  Future<bool> updateDish({
    required int id,
    required String name,
    String? description,
    required double price,
    required int categoryId,
    File? imageFile,
  }) async {
    _setLoading(true);
    try {
      final updatedDish = await _apiService.updateDish(
        id: id,
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        imageFile: imageFile,
      );
      
      final index = _dishes.indexWhere((dish) => dish.id == id);
      if (index != -1) {
        _dishes[index] = updatedDish;
      }
      
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete dish
  Future<bool> deleteDish(int id) async {
    _setLoading(true);
    try {
      await _apiService.deleteDish(id);
      _dishes.removeWhere((dish) => dish.id == id);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Set selected category
  void setSelectedCategory(Category? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Private method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
} 
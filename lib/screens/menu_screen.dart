import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../services/menu_provider.dart';
import '../models/dish.dart';
import '../widgets/dish_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import 'dish_detail_screen.dart';
import 'dish_form_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().loadDishes();
      context.read<MenuProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Menu'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DishFormScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<MenuProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.dishes.isEmpty) {
            return const LoadingWidget(message: 'Loading menu...');
          }

          if (provider.error != null && provider.dishes.isEmpty) {
            return CustomErrorWidget(
              message: provider.error!,
              onRetry: () {
                provider.clearError();
                provider.loadDishes();
                provider.loadCategories();
              },
            );
          }

          return Column(
            children: [
              // Search and filter section
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[50],
                child: Column(
                  children: [
                    // Search bar
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search dishes...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: provider.setSearchQuery,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Category filter
                    Row(
                      children: [
                        const Text(
                          'Category: ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: provider.selectedCategory?.id,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            hint: const Text('All Categories'),
                            items: [
                              const DropdownMenuItem<int>(
                                value: null,
                                child: Text('All Categories'),
                              ),
                              ...provider.categories.map((category) {
                                return DropdownMenuItem<int>(
                                  value: category.id,
                                  child: Text(category.name),
                                );
                              }).toList(),
                            ],
                            onChanged: (categoryId) {
                              if (categoryId != null) {
                                try {
                                  final category = provider.categories
                                      .firstWhere((c) => c.id == categoryId);
                                  provider.setSelectedCategory(category);
                                } catch (e) {
                                  // Handle case where category is not found
                                  provider.setSelectedCategory(null);
                                }
                              } else {
                                provider.setSelectedCategory(null);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: provider.clearFilters,
                          icon: const Icon(Icons.clear),
                          tooltip: 'Clear filters',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Results count
              if (provider.searchQuery.isNotEmpty || provider.selectedCategory != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.blue[50],
                  child: Row(
                    children: [
                      Icon(Icons.filter_list, size: 16, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        '${provider.filteredDishes.length} dishes found',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Dishes grid
              Expanded(
                child: provider.filteredDishes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No dishes found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or filters',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : MasonryGridView.count(
                        crossAxisCount: 2,
                        padding: const EdgeInsets.all(8),
                        itemCount: provider.filteredDishes.length,
                        itemBuilder: (context, index) {
                          final dish = provider.filteredDishes[index];
                          return DishCard(
                            dish: dish,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DishDetailScreen(dish: dish),
                                ),
                              );
                            },
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DishFormScreen(dish: dish),
                                ),
                              );
                            },
                            onDelete: () => _showDeleteDialog(dish),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteDialog(Dish dish) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Dish'),
        content: Text('Are you sure you want to delete "${dish.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<MenuProvider>().deleteDish(dish.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 
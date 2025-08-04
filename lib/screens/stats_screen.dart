import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/menu_provider.dart';
import '../widgets/loading_widget.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
      ),
      body: Consumer<MenuProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.dishes.isEmpty) {
            return const LoadingWidget(message: 'Loading statistics...');
          }

          final dishes = provider.dishes;
          final categories = provider.categories;

          // Calculate statistics
          final totalDishes = dishes.length;
          final totalCategories = categories.length;
          final averagePrice = dishes.isNotEmpty
              ? dishes.map((d) => d.price).reduce((a, b) => a + b) / dishes.length
              : 0.0;
          final mostExpensiveDish = dishes.isNotEmpty
              ? dishes.reduce((a, b) => a.price > b.price ? a : b)
              : null;
          final cheapestDish = dishes.isNotEmpty
              ? dishes.reduce((a, b) => a.price < b.price ? a : b)
              : null;

          // Category statistics
          final categoryStats = <String, int>{};
          for (final dish in dishes) {
            categoryStats[dish.category.name] =
                (categoryStats[dish.category.name] ?? 0) + 1;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Overview cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Dishes',
                      totalDishes.toString(),
                      Icons.restaurant_menu,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Categories',
                      totalCategories.toString(),
                      Icons.category,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Avg Price',
                      '\$${averagePrice.toStringAsFixed(2)}',
                      Icons.attach_money,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'With Images',
                      dishes.where((d) => d.imageUrl != null).length.toString(),
                      Icons.image,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Price range
              if (mostExpensiveDish != null && cheapestDish != null) ...[
                const Text(
                  'Price Range',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildPriceRow(
                          'Most Expensive',
                          mostExpensiveDish.name,
                          mostExpensiveDish.price,
                          Colors.red,
                        ),
                        const Divider(),
                        _buildPriceRow(
                          'Cheapest',
                          cheapestDish.name,
                          cheapestDish.price,
                          Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
              
              // Category breakdown
              const Text(
                'Dishes by Category',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              if (categoryStats.isNotEmpty)
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categoryStats.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final category = categoryStats.keys.elementAt(index);
                      final count = categoryStats[category]!;
                      final percentage = (count / totalDishes * 100).toStringAsFixed(1);
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          child: Text(
                            count.toString(),
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(category),
                        subtitle: Text('$percentage% of total dishes'),
                        trailing: Text(
                          '$count dishes',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No dishes found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String dishName, double price, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Text(
              dishName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          '\$${price.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
} 
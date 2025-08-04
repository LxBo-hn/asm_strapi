import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/menu_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // App Info Section
          _buildSection(
            'App Information',
            [
              _buildListTile(
                icon: Icons.info,
                title: 'App Version',
                subtitle: '1.0.0',
                onTap: null,
              ),
              _buildListTile(
                icon: Icons.description,
                title: 'Description',
                subtitle: 'Restaurant Menu Management App',
                onTap: null,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Data Management Section
          _buildSection(
            'Data Management',
            [
              _buildListTile(
                icon: Icons.refresh,
                title: 'Refresh Data',
                subtitle: 'Reload dishes and categories from server',
                onTap: () {
                  final provider = context.read<MenuProvider>();
                  provider.loadDishes();
                  provider.loadCategories();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data refreshed successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
              _buildListTile(
                icon: Icons.clear_all,
                title: 'Clear Filters',
                subtitle: 'Reset search and category filters',
                onTap: () {
                  final provider = context.read<MenuProvider>();
                  provider.clearFilters();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Filters cleared!'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // API Configuration Section
          _buildSection(
            'API Configuration',
            [
              _buildListTile(
                icon: Icons.api,
                title: 'API Base URL',
                subtitle: 'http://localhost:1337/api',
                onTap: null,
              ),
              _buildListTile(
                icon: Icons.settings,
                title: 'Connection Status',
                subtitle: 'Connected to Strapi',
                onTap: null,
                trailing: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // About Section
          _buildSection(
            'About',
            [
              _buildListTile(
                icon: Icons.code,
                title: 'Developer',
                subtitle: 'Flutter & Strapi Integration',
                onTap: null,
              ),
              _buildListTile(
                icon: Icons.bug_report,
                title: 'Report Issues',
                subtitle: 'Found a bug? Let us know!',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Feature coming soon!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // App Statistics
          Consumer<MenuProvider>(
            builder: (context, provider, child) {
              final dishes = provider.dishes;
              final categories = provider.categories;
              
              return _buildSection(
                'Current Statistics',
                [
                  _buildListTile(
                    icon: Icons.restaurant_menu,
                    title: 'Total Dishes',
                    subtitle: '${dishes.length} dishes in menu',
                    onTap: null,
                  ),
                  _buildListTile(
                    icon: Icons.category,
                    title: 'Categories',
                    subtitle: '${categories.length} categories available',
                    onTap: null,
                  ),
                  _buildListTile(
                    icon: Icons.image,
                    title: 'Dishes with Images',
                    subtitle: '${dishes.where((d) => d.imageUrl != null).length} dishes have images',
                    onTap: null,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.orange[600],
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }
} 
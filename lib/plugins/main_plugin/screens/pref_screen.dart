import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../screens/base_screen.dart';
import '../../../providers/app_state_provider.dart';
import '../functions/main_plugin_helper.dart';
import '../main_plugin_main.dart';

class PrefScreen extends BaseScreen {
  const PrefScreen({Key? key}) : super(key: key);

  @override
  String computeTitle(BuildContext context) {
    return "Preferences";
  }

  @override
  PrefScreenState createState() => PrefScreenState();
}

class PrefScreenState extends BaseScreenState<PrefScreen> {
  bool _isLoading = true; // Track loading state
  List<Map<String, dynamic>> _categoriesWithLevels = []; // Store categories with levels

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);

    // Fetch categories using PluginHelper
    final categories = await PluginHelper.getCategories(appStateProvider);

    // Get the logged-in user state
    final loggedIn = appStateProvider.getPluginState('LoginPluginState')?['logged'] ?? false;
    final categoryLevels = appStateProvider.getPluginState('LoginPluginState')?['category_levels'] ?? {};

    if (categories is List) {
      setState(() {
        if (loggedIn) {
          // Update categories with their levels
          _categoriesWithLevels = categories.map<Map<String, dynamic>>((category) {
            // Normalize category key
            final categoryKey = 'level_${category.replaceAll(' ', '_').toLowerCase()}';

            // Get level or log missing keys
            final categoryLevel = categoryLevels[categoryKey] ?? 'N/A';
            if (categoryLevel == 'N/A') {
              print('Missing level for category: $category (key: $categoryKey)');
            }

            return {
              'category': category,
              'level': categoryLevel,
            };
          }).toList();
        } else {
          _categoriesWithLevels = categories.map<Map<String, dynamic>>((category) {
            return {'category': category, 'level': 'N/A'};
          }).toList();
        }
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleCategorySelection(String category) async {
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    await PluginHelper.updateCategory(category, appStateProvider, context);
  }

  @override
  @override
  Widget buildContent(BuildContext context) {
    String? selectedCategory; // Track the currently selected category

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Categories",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          )
        else if (_categoriesWithLevels.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Select a category",
              ),
              value: selectedCategory,
              isExpanded: true,
              items: _categoriesWithLevels.map<DropdownMenuItem<String>>((entry) {
                final category = entry['category'];
                final level = entry['level'];
                return DropdownMenuItem<String>(
                  value: category, // Use the category as the value
                  child: Text("$category (Level $level)"),
                );
              }).toList(),
              onChanged: (value) async {
                if (value != null) {
                  selectedCategory = value;
                  await _handleCategorySelection(value);
                  setState(() {}); // Update the UI to reflect the selection
                }
              },
            ),
          )
        else
          const Center(
            child: Text(
              "No categories available.",
              style: TextStyle(fontSize: 16),
            ),
          ),
      ],
    );
  }

}

// pref_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../screens/base_screen.dart';
import '../../../providers/app_state_provider.dart';
import '../../main_plugin/functions/main_plugin_helper.dart';
import '../../../services/shared_preferences_service.dart';
import '../main_plugin_main.dart';

class PrefScreen extends BaseScreen {
  const PrefScreen({Key? key}) : super(key: key);

  @override
  String get title => "Preferences";

  @override
  Widget buildContent(BuildContext context) {
    return CategorySelection();
  }
}

class CategorySelection extends StatefulWidget {
  @override
  _CategorySelectionState createState() => _CategorySelectionState();
}

class _CategorySelectionState extends State<CategorySelection> {
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadInitialCategory();
  }

  Future<void> _loadInitialCategory() async {
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    final pluginStateKey = "${MainPlugin().runtimeType}State";
    final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey);

    // Check plugin state for existing category, otherwise check SharedPreferences
    String celebCategory = pluginState?["celeb_category"] ?? "";

    if (celebCategory.isEmpty) {
      celebCategory = SharedPreferencesService().getString("celeb_category") ?? "";
    }

    if (celebCategory.isNotEmpty) {
      setState(() {
        selectedCategory = celebCategory;
      });
    }
  }

  Future<void> _updateCategory(String category) async {
    // Update AppStateProvider and SharedPreferences with the new category
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    final pluginStateKey = "${MainPlugin().runtimeType}State";
    appStateProvider.updatePluginState(pluginStateKey, {
      "celeb_category": category,
      "celeb_name": "",
      "celeb_img_url": "",
      "celeb_facts": []
    });

    await SharedPreferencesService().setString("celeb_category", category);

    setState(() {
      selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(height: 20),
        const Text("Select a Category", style: TextStyle(fontSize: 20)),
        // Limit the height to half of the screen's height
        Container(
          height: MediaQuery.of(context).size.height * 0.5,
          child: FutureBuilder<dynamic>(
            future: PluginHelper.getCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || (snapshot.data is Map && snapshot.data.containsKey('error'))) {
                final error = snapshot.data?['error'] ?? "Failed to load categories.";
                return Center(child: Text(error));
              } else {
                // Display radio buttons for each category in a scrollable list
                final categories = snapshot.data as List<dynamic>;
                return ListView(
                  children: categories.map<Widget>((category) {
                    return RadioListTile<String>(
                      title: Text(category.toString()),
                      value: category.toString(),
                      groupValue: selectedCategory,
                      onChanged: (value) {
                        if (value != null) {
                          _updateCategory(value);
                        }
                      },
                    );
                  }).toList(),
                );
              }
            },
          ),
        ),
        if (selectedCategory != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Selected Category: $selectedCategory", style: TextStyle(fontSize: 18)),
          ),
      ],
    );
  }
}

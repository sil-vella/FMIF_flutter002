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
    // Return a fixed title for the screen
    return "Preferences";
  }

  @override
  PrefScreenState createState() => PrefScreenState();
}

// Rename _PrefScreenState to PrefScreenState
class PrefScreenState extends BaseScreenState<PrefScreen> {
  bool _isLoading = true; // Track loading state
  List<dynamic> _categories = []; // Store fetched categories

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    final categories = await PluginHelper.getCategories(appStateProvider);

    if (categories is List) {
      setState(() {
        _categories = categories;
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
  Widget buildContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Preferences",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          )
        else if (_categories.isNotEmpty)
          Expanded(
            child: ListView(
              children: _categories.map<Widget>((category) {
                return RadioListTile<String>(
                  title: Text(category.toString()),
                  value: category.toString(),
                  groupValue: context.select<AppStateProvider, String?>((appStateProvider) {
                    final pluginStateKey = "${MainPlugin().runtimeType}State";
                    return appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey)?['celeb_category'];
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      _handleCategorySelection(value);
                    }
                  },
                );
              }).toList(),
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

import 'package:flush_me_im_famous/utils/consts/theme_consts.dart';
import 'package:flush_me_im_famous/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state_provider.dart';
import '../../../screens/base_screen.dart';
import '../../00_base/module_manager.dart';

class LoginScreen extends BaseScreen {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  String computeTitle(BuildContext context) {
    // Dynamically get the logged-in state
    final isLoggedIn = context.select<AppStateProvider, bool>(
          (state) => state.getPluginState("LoginPluginState")?['logged'] ?? false,
    );
    return isLoggedIn ? "Account" : "Login/Register";
  }

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends BaseScreenState<LoginScreen> {
  // Persistent ValueNotifier for login/register toggle
  final ValueNotifier<bool> isLogin = ValueNotifier<bool>(true);

  @override
  void dispose() {
    isLogin.dispose(); // Dispose notifier to avoid memory leaks
    super.dispose();
  }

  @override
  Widget buildContent(BuildContext context) {
    final pluginStateKey = "LoginPluginState";
    final isLoggedIn = context.select<AppStateProvider, bool>(
          (state) => state.getPluginState(pluginStateKey)?['logged'] ?? false,
    );

    final loginModuleFactory = ModuleManager().getFunction<Function>("LoginModule");
    final registerModuleFactory = ModuleManager().getFunction<Function>("RegisterModule");

    final loginModule = loginModuleFactory?.call();
    final registerModule = registerModuleFactory?.call();

    if (loginModule == null || registerModule == null) {
      return const Center(child: Text('Modules not found'));
    }

    return Center(
      child: isLoggedIn
          ? _buildLoggedInView(context, pluginStateKey)
          : ValueListenableBuilder<bool>(
        valueListenable: isLogin,
        builder: (context, _isLogin, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _isLogin ? loginModule.loginUI(context) : registerModule.registerUI(context),
              TextButton(
                onPressed: () {
                  isLogin.value = !_isLogin; // Toggle between Login and Register
                },
                child: Text(
                  _isLogin ? 'Switch to Register' : 'Switch to Login',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoggedInView(BuildContext context, String pluginStateKey) {
    final username = context.select<AppStateProvider, String>(
          (state) => state.getPluginState(pluginStateKey)?['username'] ?? 'Unknown User',
    );
    final points = context.select<AppStateProvider, String>(
          (state) => state.getPluginState(pluginStateKey)?['points']?.toString() ?? '0',
    );

    // Retrieve the category levels (which is a map)
    final categoryLevels = context.select<AppStateProvider, Map<String, dynamic>>(
          (state) => state.getPluginState(pluginStateKey)?['category_levels'] ?? {},
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Welcome, $username!',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.accentColor2),
        ),
        const SizedBox(height: 8.0),
        Text('Score: $points'),
        const SizedBox(height: 16.0),

// Dynamically display category levels with headings
        if (categoryLevels.isNotEmpty)
          Column(
            children: [
              // Heading row
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Category Heading
                    Expanded(
                      child: Center(
                        child: Text(
                          'Category',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.accentColor,
                          ),
                        ),
                      ),
                    ),
                    // Level Heading
                    Expanded(
                      child: Center(
                        child: Text(
                          'Level',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.accentColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Category and Level Rows
              ...categoryLevels.entries.map((entry) {
                String categoryName = entry.key.replaceAll('level_', '').replaceAll('_', ' ').capitalizeFirstOfEach;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,  // Center the entire row
                    children: [
                      // Category Name Column
                      Expanded(
                        child: Center(
                          child: Text(
                            categoryName,  // Display the category name
                            style: const TextStyle(
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                      // Level Column
                      Expanded(
                        child: Center(
                          child: Text(
                            'Level ${entry.value.toString()}',  // Display the level number
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),

        const SizedBox(height: 16.0),

        // Logout button
        ElevatedButton(
          onPressed: () async {
            final loginModuleFactory = ModuleManager().getFunction<Function>("LoginModule");
            final loginModule = loginModuleFactory?.call();
            if (loginModule != null) {
              await loginModule.logout(context);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Logged out successfully')),
            );
          },
          child: const Text('Logout'),
        ),
      ],
    );
  }

}

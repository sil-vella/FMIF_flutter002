import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/app_state_provider.dart';
import '../../../api/modules/connection_module.dart';

class LoginModule {
  final ConnectionModule connectionModule;

  LoginModule({required this.connectionModule});

  final String pluginStateKey = "LoginPluginState"; // State key for this module

  /// Sends login data to the backend
  Future<Map<String, dynamic>> login(
      String username, String password, BuildContext context) async {
    final response = await connectionModule.sendPostRequest(
      '/login',
      {'username': username, 'password': password},
    );

    if (response['token'] != null) {
      // Update the plugin state with login details
      final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);

      // Prepare the category levels map from response
      final categoryLevels = response['category_levels'] ?? {};

      await appStateProvider.updatePluginState(pluginStateKey, {
        "logged": true,
        "username": username, // Set the username
        "points": response['points'], // Set the points from response
        "category_levels": categoryLevels, // Store the category levels
      });

      return {
        'success': true,
        'token': response['token'],
        'points': response['points'],
        'category_levels': categoryLevels, // Include the category levels in the return data
      };
    } else {
      return {
        'success': false,
        'message': response['message'] ?? 'An error occurred',
      };
    }
  }

  Future<Map<String, dynamic>> getUserDetails({
    required String username,
  }) async {
    // Append the username as a query parameter
    final route = '/user-details?username=$username';

    // Call the sendGetRequest method with the modified route
    final response = await connectionModule.sendGetRequest(route);

    if (response['success'] == true) {
      return {
        'success': true,
        'points': response['points'],
        'category_levels': response['category_levels'],
      };
    } else {
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to fetch user details',
      };
    }
  }

  /// Logs the user out and updates the state
  Future<void> logout(BuildContext context) async {
    // Update the plugin state to logged out
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    await appStateProvider.updatePluginState(pluginStateKey, {
      "logged": false,
      "username": null, // Clear username
      "points": null, // Clear points
    });
  }

  /// Displays the login UI
  Widget loginUI(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Allow the column to shrink-wrap its content
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextField(
            controller: usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            width: double.infinity, // Take up available width
            child: ElevatedButton(
              onPressed: () async {
                final result = await login(
                  usernameController.text,
                  passwordController.text,
                  context,
                );

                if (result['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Login successful!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login failed: ${result['message']}')),
                  );
                }
              },
              child: const Text('Login'),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../api/modules/connection_module.dart';

class RegisterModule {
  final ConnectionModule connectionModule;

  RegisterModule({required this.connectionModule});

  /// Sends registration data to the backend
  Future<Map<String, dynamic>> register(String username, String password) async {
    final response = await connectionModule.sendPostRequest(
      '/register',
      {'username': username, 'password': password},
    );

    if (response['message'] == 'User registered successfully') {
      return {
        'success': true,
        'message': response['message'],
      };
    } else {
      return {
        'success': false,
        'message': response['message'] ?? 'An error occurred',
      };
    }
  }

  /// Displays the registration UI
  Widget registerUI(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

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
          TextField(
            controller: confirmPasswordController,
            decoration: const InputDecoration(
              labelText: 'Confirm Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }

              final result = await register(
                usernameController.text,
                passwordController.text,
              );

              if (result['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'])),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'])),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48), // Full width, fixed height
            ),
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}

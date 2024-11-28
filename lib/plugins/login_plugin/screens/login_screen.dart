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
    final level = context.select<AppStateProvider, String>(
          (state) => state.getPluginState(pluginStateKey)?['level']?.toString() ?? 'N/A',
    );
    final points = context.select<AppStateProvider, String>(
          (state) => state.getPluginState(pluginStateKey)?['points']?.toString() ?? '0',
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Welcome, $username!',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        Text('Level: $level'),
        Text('Points: $points'),
        const SizedBox(height: 16.0),
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

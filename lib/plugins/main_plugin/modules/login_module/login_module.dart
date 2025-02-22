import 'package:flush_me_im_famous/core/00_base/module_base.dart';
import '../../../../core/managers/module_manager.dart';
import '../../../../core/managers/services_manager.dart';
import '../../../../tools/logging/logger.dart';
import '../connections_module/connections_module.dart';

class LoginModule extends ModuleBase {
  static final Logger _log = Logger(); // ✅ Use a static logger for static methods
  final ServicesManager servicesManager = ServicesManager();
  final ModuleManager _moduleManager = ModuleManager();

  /// ✅ Constructor with module key
  LoginModule() : super("login_module") {
    _log.info('✅ LoginModule initialized.');
  }

  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    final connectionModule = _moduleManager.getLatestModule<ConnectionsModule>();
    final sharedPrefService = servicesManager.getService('shared_pref');

    if (connectionModule == null || sharedPrefService == null) {
      _log.error("❌ Missing required modules.");
      return {"error": "Service not available."};
    }

    // ✅ Fetch available categories from SharedPreferences
    List<String> categories = await sharedPrefService.callServiceMethod('getStringList', ['available_categories']) ?? [];

    if (categories.isEmpty) {
      _log.error("⚠️ No categories found in SharedPreferences. Defaulting to 'mixed'.");
      categories = ['mixed']; // ✅ Ensure at least one category exists
    }

    // ✅ Fetch levels dynamically for each category
    Map<String, int> categoryLevels = {};
    for (String category in categories) {
      int levels = await sharedPrefService.callServiceMethod('getInt', ['max_levels_$category']) ?? 5; // ✅ Correct level count
      categoryLevels[category] = levels;
    }

    // ✅ Fetch points & levels for each category from SharedPreferences
    Map<String, dynamic> categoryProgress = {};
    for (String category in categories) {
      int currentLevel = await sharedPrefService.callServiceMethod('getInt', ['level_$category']) ?? 1;
      int categoryPoints = await sharedPrefService.callServiceMethod('getInt', ['points_${category}_level$currentLevel']) ?? 0;

      categoryProgress[category] = {
        "points": categoryPoints,
        "level": currentLevel
      };
    }

    // ✅ Fetch guessed names per category and level
    Map<String, Map<String, List<String>>> guessedNames = {};
    for (String category in categories) {
      Map<String, List<String>> levelGuessedNames = {};

      int maxLevels = categoryLevels[category] ?? 5; // ✅ Correctly use fetched levels

      for (int lvl = 1; lvl <= maxLevels; lvl++) {
        String guessedKey = "guessed_${category}_level$lvl";
        List<String> guessedList = await sharedPrefService.callServiceMethod('getStringList', [guessedKey]) ?? [];
        levelGuessedNames["level_$lvl"] = guessedList;
      }

      guessedNames[category] = levelGuessedNames;
    }

    try {
      _log.info("⚡ Sending registration request to `/register` with category-based data...");
      _log.info("📝 Registering user with password: $password"); // 🔥 Debug log


      final response = await connectionModule.sendPostRequest(
        "/register",
        {
          "username": username,
          "email": email,
          "password": password,
          "category_progress": categoryProgress, // ✅ Points & levels per category
          "guessed_names": guessedNames, // ✅ Guessed names per category & level
        },
      );

      if (response != null && response['message'] == "User registered successfully") {
        _log.info("✅ User registered successfully. Auto logging in...");
        return await loginUser(email: email, password: password);
      } else {
        return {"error": response?["error"] ?? "Failed to register user."};
      }
    } catch (e) {
      _log.error("❌ Registration error: $e");
      return {"error": "Server error. Check network connection."};
    }
  }

  /// ✅ User Login Logic (Updated for Category, Level, and Guessed Names)
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final connectionModule = _moduleManager.getLatestModule<ConnectionsModule>();
    final sharedPrefService = servicesManager.getService('shared_pref');

    if (connectionModule == null || sharedPrefService == null) {
      _log.error("❌ Missing required modules.");
      return {"error": "Service not available."};
    }

    try {
      _log.info("⚡ Sending login request...");

      final response = await connectionModule.sendPostRequest(
        "/login",
        {
          "email": email,
          "password": password,
        },
      );

      // ✅ Log the full server response for debugging
      _log.info("📡 Server Response: $response");
      _log.forceLog("📡 Server Response: $response");

      if (response != null && response.containsKey('message') && response['message'] == "Login successful") {
        if (!response.containsKey("user") || !response["user"].containsKey("id")) {
          return {"error": "Invalid server response."};
        }

        final user = response["user"];

        // ✅ Store updated user details in SharedPreferences
        await sharedPrefService.callServiceMethod('setString', ['email', email]);
        await sharedPrefService.callServiceMethod('setString', ['username', user["username"]]);
        await sharedPrefService.callServiceMethod('setString', ['password', password]); // ✅ Save original password
        await sharedPrefService.callServiceMethod('setInt', ['user_id', user["id"]]);  // ✅ Save user ID
        await sharedPrefService.callServiceMethod('setBool', ['is_logged_in', true]);

        _log.info("✅ User login successful. User ID: ${user["id"]}");

        // ✅ Fetch and update category-based progress
        if (user.containsKey("category_progress") && user["category_progress"] is Map<String, dynamic>) {
          Map<String, dynamic> categoryProgress = user["category_progress"];

          for (String category in categoryProgress.keys) {
            Map<String, dynamic> progress = categoryProgress[category];
            int points = progress.containsKey("points") ? progress["points"] : 0;
            int level = progress.containsKey("level") ? progress["level"] : 1;

            await sharedPrefService.callServiceMethod('setInt', ['points_${category}_level$level', points]);
            await sharedPrefService.callServiceMethod('setInt', ['level_$category', level]);

            _log.info("📊 Updated progress for $category Level $level: Points=$points | Level=$level");
          }
        } else {
          _log.error("⚠️ No category progress found in the login response.");
        }

        // ✅ Fetch and update guessed names from the backend
        if (user.containsKey("guessed_names") && user["guessed_names"] is Map<String, dynamic>) {
          Map<String, dynamic> guessedNames = user["guessed_names"];

          for (String category in guessedNames.keys) {
            Map<String, dynamic> levelGuessedNames = guessedNames[category]; // ✅ Ensure levels exist

            for (String levelKey in levelGuessedNames.keys) {
              List<String> namesList = List<String>.from(levelGuessedNames[levelKey] ?? []);
              if (namesList.isNotEmpty) {
                String guessedKey = "guessed_${category}_${levelKey.replaceAll("level_", "level")}";
                await sharedPrefService.callServiceMethod('setStringList', [guessedKey, namesList]);

                _log.info("📜 Updated guessed names for $category $levelKey: $namesList");
              }
            }
          }
        } else {
          _log.error("⚠️ No guessed names found in the login response.");
        }

        return {"success": "Login Successful!"};
      } else {
        return {"error": response?["error"] ?? "Invalid email or password."};
      }
    } catch (e) {
      _log.error("❌ Login error: $e");
      return {"error": "Server error. Check network connection."};
    }
  }
  /// ✅ Delete User Method
  Future<Map<String, dynamic>> deleteUser() async {
    final connectionModule = _moduleManager.getLatestModule<ConnectionsModule>();
    final sharedPrefService = servicesManager.getService('shared_pref');

    if (connectionModule == null || sharedPrefService == null) {
      _log.error("❌ Missing required modules.");
      return {"error": "Service not available."};
    }

    int? userId = await sharedPrefService.callServiceMethod('getInt', ['user_id']);

    if (userId == null) {
      _log.error("❌ No user ID found. Cannot delete account.");
      return {"error": "User not logged in or ID missing."};
    }

    try {
      _log.info("⚡ Sending delete request for User ID: $userId...");

      final response = await connectionModule.sendPostRequest(
        "/delete-user",
        {"user_id": userId},
      );

      _log.info("📡 Server Response: $response");

      if (response == null) {
        return {"error": "No response from server. Check network connection."};
      }

      if (response.containsKey('message')) {
        await sharedPrefService.callServiceMethod('remove', ['user_id']);
        await sharedPrefService.callServiceMethod('remove', ['username']);
        await sharedPrefService.callServiceMethod('remove', ['email']);
        await sharedPrefService.callServiceMethod('remove', ['is_logged_in']);

        return {"success": "Account deleted successfully!"};
      } else {
        return {"error": response?["error"] ?? "Failed to delete account."};
      }
    } catch (e) {
      _log.error("❌ Error deleting user: $e");
      return {"error": "Server error. Check network connection."};
    }
  }

}


import '../../../../core/00_base/module_base.dart';
import '../../../../core/managers/module_manager.dart';
import '../../../../core/managers/services_manager.dart';
import '../../../../tools/logging/logger.dart';
import '../../../main_plugin/modules/connections_module/connections_module.dart';

class QuestionModule extends ModuleBase {
  static final Logger _log = Logger(); // ✅ Use a static logger for static methods
  final ServicesManager _servicesManager = ServicesManager();

  /// ✅ Constructor with module key
  QuestionModule() : super("question_module") {
    _log.info('✅ QuestionModule initialized.');
  }

  /// ✅ Retrieve guessed names from SharedPreferences
  Future<List<String>> getGuessedNames(String category, int level) async {
    final sharedPref = _servicesManager.getService('shared_pref');

    if (sharedPref == null) {
      _log.error("❌ SharedPreferences service not available.");
      return [];
    }

    String guessedKey = "guessed_${category}_level$level";
    List<String> guessedNames = await sharedPref.callServiceMethod('getStringList', [guessedKey]) ?? [];

    _log.info("📜 Retrieved guessed names for $category Level $level: $guessedNames");
    return guessedNames;
  }

  /// ✅ Fetch a question from the backend
  Future<Map<String, dynamic>> getQuestion(int difficulty, String category, List<String> guessedNames) async {
    final connectionModule = ModuleManager().getLatestModule<ConnectionsModule>();

    if (connectionModule == null) {
      _log.error("❌ ConnectionModule not found in QuestionModule.");
      return {"error": "Connection module not available"};
    }

    try {
      // ✅ Build request payload including guessed names
      final payload = {
        "level": difficulty,
        "category": category,
        "guessed_names": guessedNames,
      };

      _log.info("⚡ Sending POST request to `/get-question` with payload: $payload");

      final response = await connectionModule.sendPostRequest("/get-question", payload);

      _log.info("✅ Response from backend: $response");
      return response;
    } catch (e) {
      _log.error("❌ Error fetching question from backend: $e", error: e);
      return {"error": "Failed to fetch question from server"};
    }
  }

  /// ✅ Checks if the given answer matches the correct answer
  bool checkAnswer(String input, String correctAnswer) {
    return input.trim().toLowerCase() == correctAnswer.trim().toLowerCase();
  }

  /// ✅ Dispose method to clean up resources
  @override
  void dispose() {
    _log.info("🗑 QuestionModule disposed.");
    super.dispose();
  }
}

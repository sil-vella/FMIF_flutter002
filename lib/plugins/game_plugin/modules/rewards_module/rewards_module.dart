import 'package:flush_me_im_famous/plugins/game_plugin/modules/function_helper_module/function_helper_module.dart';
import 'package:flush_me_im_famous/plugins/game_plugin/modules/rewards_module/rewardsModule_config/config.dart';
import '../../../../core/00_base/module_base.dart';
import '../../../../core/managers/module_manager.dart';
import '../../../../core/managers/services_manager.dart';
import '../../../../tools/logging/logger.dart';
import '../../../main_plugin/modules/connections_module/connections_module.dart';

class RewardsModule extends ModuleBase {
  static final Logger _log = Logger(); // ✅ Use a static logger for static methods
  final ServicesManager _servicesManager = ServicesManager();
  final ModuleManager _moduleManager = ModuleManager();

  /// ✅ Constructor with module key
  RewardsModule() : super("rewards_module") {
    _log.info('✅ RewardsModule initialized.');
  }

  /// ✅ Get points for a specific action, applying the multiplier for the provided level
  Future<int> getPoints(String key, String category, int level) async {
    final sharedPref = _servicesManager.getService('shared_pref');

    if (sharedPref == null) {
      _log.error('❌ SharedPreferences service not available.');
      return 0;
    }

    // ✅ Fetch the base points using `key`
    int basePoints = RewardsConfig.baseRewards[key] ?? 1;

    // ✅ Fetch the level multiplier based on the provided level
    double multiplier = RewardsConfig.levelMultipliers[level] ?? 1.0;

    _log.info('🏆 Calculating points for $key at Level $level: Base = $basePoints, Multiplier = $multiplier');

    return (basePoints * multiplier).toInt();
  }

  /// ✅ Save Reward and Update Backend
  Future<Map<String, dynamic>> saveReward({
    required int points,
    required String category,
    required int level,
    required String guessedActor,
  }) async {
    final sharedPref = _servicesManager.getService('shared_pref');
    final connectionModule = _moduleManager.getLatestModule<ConnectionsModule>();
    final functionsHelper = _moduleManager.getLatestModule<FunctionHelperModule>();

    if (sharedPref == null || connectionModule == null || functionsHelper == null) {
      _log.error('❌ SharedPreferences, ConnectionModule, or FunctionsHelperModule not available.');
      return {"points": 0, "endGame": false, "levelUp": false};
    }

    // ✅ Retrieve current level & points
    int currentLevel = level;
    int previousPoints = await sharedPref.callServiceMethod('getInt', ['points_${category}_level$currentLevel']) ?? 0;
    int updatedPoints = previousPoints + points;

    // ✅ Fetch guessed names for this level
    String guessedKey = "guessed_${category}_level$currentLevel";
    List<String> guessedList = await sharedPref.callServiceMethod('getStringList', [guessedKey]) ?? [];

    if (!guessedList.contains(guessedActor)) {
      guessedList.add(guessedActor);
      await sharedPref.callServiceMethod('setStringList', [guessedKey, guessedList]);
      _log.info("📜 Updated guessed names for $category Level $currentLevel: $guessedList");
    }

    // ✅ Retrieve user details
    final userId = await sharedPref.callServiceMethod('getInt', ['user_id']);
    final username = await sharedPref.callServiceMethod('getString', ['username']);
    final email = await sharedPref.callServiceMethod('getString', ['email']);

    await sharedPref.callServiceMethod('setInt', ['points_${category}_level$currentLevel', updatedPoints]);
    int totalPoints = await functionsHelper.getTotalPoints(); // ✅ Get updated total

    // ✅ Backend request to update rewards
    Map<String, dynamic> response = {};
    try {
      _log.info("⚡ Sending updated rewards to backend...");

      response = await connectionModule.sendPostRequest(
        "/update-rewards",
        {
          "user_id": userId,
          "username": username,
          "email": email,
          "category": category,
          "level": currentLevel,
          "points": updatedPoints,
          "guessed_names": guessedList,
          "total_points": totalPoints,
        },
      );

      _log.forceLog("📜 Response from backend: $response");

      if (response == null || !response.containsKey("message")) {
        _log.error("❌ Invalid response from backend.");
      }

      if (response["message"] != "Rewards updated successfully") {
        _log.error("❌ Backend error: ${response["error"] ?? "Unknown error"}");
      }
    } catch (e) {
      _log.error("❌ Error while updating rewards: $e", error: e);
    }

    // ✅ Update SharedPreferences based on backend response
    bool levelUp = response["levelUp"] ?? false;
    bool endGame = response["endGame"] ?? false;
    int newLevel = levelUp ? currentLevel + 1 : currentLevel;

    await sharedPref.callServiceMethod('setInt', ['level_$category', newLevel]);

    _log.forceLog("📜 SharedPreferences total after update: $totalPoints");
    _log.info("🏆 Updated Rewards: Points: $updatedPoints | Level: $newLevel | Level Up: $levelUp | EndGame: $endGame");

    return {
      "points": updatedPoints,
      "endGame": endGame,
      "levelUp": levelUp,
      "totalPoints": totalPoints,
    };
  }

  /// ✅ Dispose method to clean up resources
  @override
  void dispose() {
    _log.info("🗑 RewardsModule disposed.");
    super.dispose();
  }
}

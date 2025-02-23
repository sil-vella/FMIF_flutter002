import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/00_base/module_base.dart';
import '../../../../core/managers/app_manager.dart';
import '../../../../core/managers/module_manager.dart';
import '../../../../core/managers/services_manager.dart';
import '../../../../core/managers/state_manager.dart';
import '../../../../core/services/shared_preferences.dart';
import '../../../../tools/logging/logger.dart';
import '../../../adverts_plugin/modules/admobs/rewarded/rewarded_ad.dart';
import '../../../main_plugin/modules/main_helper_module/main_helper_module.dart';
import '../question_module/question_module.dart';
import '../rewards_module/rewards_module.dart';
import 'config/gameplaymodule_config.dart';

class GamePlayModule extends ModuleBase {
  static final Logger _log = Logger(); // ✅ Use a static logger for static methods

  /// ✅ Constructor with module key
  GamePlayModule() : super("game_play_module") {
    _log.info('📢 GamePlayModule initialized and auto-registered.');
  }

  Map<String, dynamic>? question;
  bool isLoading = true;
  String feedbackMessage = "";
  List<String> imageOptions = []; // ✅ Store shuffled images

  Future<void> resetState(BuildContext context) async {
    final stateManager = Provider.of<StateManager>(context, listen: false);

    stateManager.updatePluginState("game_timer", {
      "isRunning": false,
      "duration": 30,
    }, force: true);

    stateManager.updatePluginState("game_round", {
      "hint": false,
      "imagesLoaded": false,
      "factLoaded": false,
      "levelUp": false,
      "endGame": false,
    }, force: true);

    _log.info("✅ Game state reset completed.");

    // ✅ Wait a frame to ensure updates are reflected before proceeding
    await Future.delayed(Duration(milliseconds: 50));
  }

  /// Fetch user level and request a question from backend
  Future<void> roundInit(BuildContext context, Function updateState) async {
    final stateManager = Provider.of<StateManager>(context, listen: false);
    final sharedPref = Provider.of<ServicesManager>(context, listen: false).getService<SharedPrefManager>();

    if (sharedPref == null) {
      _log.error("❌ SharedPrefManager not found!");
      return;
    }

    final questionModule = Provider.of<ModuleManager>(context, listen: false).getLatestModule<QuestionModule>();

    if (questionModule == null) {
      _log.error("❌ QuestionModule not found!");
      return;
    }

    // ✅ Retrieve game round state
    final gameRoundState = stateManager.getPluginState<Map<String, dynamic>>('game_round');
    final int roundNumber = gameRoundState?['roundNumber'] ?? 1;
    int updatedNumber = roundNumber + 1; // ✅ Increment round

    stateManager.updatePluginState("game_round", {
      "roundNumber": updatedNumber, // ✅ Update state
    });

    // ✅ Show an ad every 5 rounds
    if (updatedNumber % 5 == 0) {
      final rewardedAdModule = Provider.of<ModuleManager>(context, listen: false).getLatestModule<RewardedAdModule>();
      final mainHelper = Provider.of<ModuleManager>(context, listen: false).getLatestModule<MainHelperModule>();

      if (rewardedAdModule != null && mainHelper != null) {
        mainHelper.pauseTimer(context); // ✅ Pause timer for ad

        rewardedAdModule.showAd(
          context,
          onUserEarnedReward: () => Logger().info("Advert Played."),
          onAdDismissed: () {
            Future.delayed(const Duration(milliseconds: 500), () {
              mainHelper.resumeTimer(context, () {
                Logger().info("⏳ Timer resumed after ad.");
              });
            });
          },
        );

      } else {
        Logger().info("❌ RewardedAdModule or MainHelperModule not found!");
      }
    }

    await resetState(context);  // ✅ Ensure state resets before fetching new data

    try {
      // ✅ Get user's level and category from SharedPreferences
      final category = sharedPref.getString('category') ?? "mixed";
      final int level = sharedPref.getInt('level_$category') ?? 1;

      _log.info("🏆 User category: $category | Level: $level");

      final guessedKey = "guessed_${category}_level$level";
      List<String> guessedNames = sharedPref.getStringList(guessedKey) ?? [];

      _log.info("📜 Final guessed names sent to backend: $guessedNames");

      // ✅ Fetch question with updated guessed list
      final response = await questionModule.getQuestion(context, level, category, guessedNames);

      if (response.containsKey("error")) {
        if (response["error"].contains("No more actors left")) {
          _log.info("🏆 All celebrities have been guessed! Consider resetting.");
        } else {
          _log.error("❌ Error fetching question: ${response['error']}");
        }
        return;
      }

      // ✅ Process the received question
      question = response;
      isLoading = false;

      // ✅ Prepare shuffled images (correct + 3 distractors)
      imageOptions = [response['image_url'], ...response['distractor_images']];
      imageOptions.shuffle(Random());

      // ✅ Update UI State in GameScreen
      updateState();
      _log.info("✅ Question retrieved successfully: $response");

    } catch (e) {
      _log.error("❌ Failed to fetch question: $e", error: e);
    }
  }

  Future<void> setTimer(BuildContext context, Function onTimeout) async {
    final sharedPref = Provider.of<ServicesManager>(context, listen: false).getService<SharedPrefManager>();

    if (sharedPref == null) {
      _log.error("❌ SharedPrefManager not found!");
      return;
    }

    try {
      final int level = sharedPref.getInt('level') ?? 1;

      if (level <= 2) {
        _log.info("⏳ Skipping timer. Level is $level.");
        return;
      }

      final int duration = (GamePlayConfig.levelTimers[level] ?? 10).toInt();

      _log.info("⏳ Starting timer for Level $level: $duration seconds");

      final stateManager = Provider.of<StateManager>(context, listen: false);

      stateManager.updatePluginState("game_timer", {
        "isRunning": true,
        "duration": duration,
      });

      final mainHelper = Provider.of<ModuleManager>(context, listen: false).getLatestModule<MainHelperModule>();
      mainHelper?.startTimer(context, duration, () {
        _log.info("⏰ Timer finished! Triggering timeout answer.");

        stateManager.updatePluginState("game_timer", {
          "isRunning": false,
          "duration": 0,
        });

        onTimeout();
      });

    } catch (e) {
      _log.error("❌ Failed to start timer: $e", error: e);
    }
  }

  void checkAnswer(BuildContext context, String selectedImage, Function updateState, {bool timeUp = false}) async {

    _log.info("🏆 Checking answer...");

    final correctImage = question?['image_url'] ?? "";
    final rewardsModule = ModuleManager().getLatestModule<RewardsModule>();
    final stateManager = Provider.of<StateManager>(context, listen: false);

    if (rewardsModule == null || stateManager == null) {
      _log.error("❌ RewardsModule or StateManager not found.");
      return;
    }

    // ✅ Extract category, level, and correct actor
    String category = question?["category"] ?? "mixed";
    int level = int.tryParse(question?["level"]?.toString() ?? "1") ?? 1;
    String correctActor = question?["actor"] ?? "";

    _log.info("📌 Checking answer for: $correctActor (Category: $category, Level: $level)");
    _log.forceLog("📌 Checking answer for: $correctActor (Category: $category, Level: $level)");

    if (selectedImage == correctImage) {
      feedbackMessage = "🎉 Correct!";

      // ✅ Retrieve 'hint' state from StateManager
      final gameRoundState = stateManager.getPluginState<Map<String, dynamic>>('game_round');
      final bool hintUsed = gameRoundState?['hint'] ?? false;

      _log.forceLog("📌 hint: $hintUsed ");

      // ✅ Determine points based on hint usage
      String pointsKey = hintUsed ? 'hint' : 'no_hint';
      int points = await rewardsModule.getPoints(context, pointsKey, category, level);

      _log.forceLog("📌 hint: $points ");

      // ✅ Call saveReward with all necessary data
      final rewardData = await rewardsModule.saveReward(
        context: context, // ✅ Pass context here
        points: points,
        category: category,
        level: level,
        guessedActor: correctActor,
      );

      Logger().forceLog("📜 reward data if correct ${rewardData}");
      _log.info("🏆 Updated Rewards: ${rewardData}");

      // ✅ Update game state with level-up or end-game status
      stateManager.updatePluginState("game_round", {
        if (rewardData["levelUp"]) "levelUp": true,
        if (rewardData["endGame"]) "endGame": true,
      });

    } else {
      feedbackMessage = "❌ Incorrect.";
    }

    updateState();
    _log.info("✅ User selected: $selectedImage | Correct: ${question?['image_url']}");
  }

void showGameOverScreen() {
  _log.info("🎯 Game over! Player reached max level.");
}

}

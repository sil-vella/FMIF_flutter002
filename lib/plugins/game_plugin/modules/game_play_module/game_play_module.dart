import 'dart:math';
import 'package:flush_me_im_famous/plugins/main_plugin/modules/main_helper_module/main_helper_module.dart';
import 'package:provider/provider.dart';
import '../../../../core/00_base/module_base.dart';
import '../../../../core/managers/app_manager.dart';
import '../../../../core/managers/module_manager.dart';
import '../../../../core/managers/services_manager.dart';
import '../../../../core/managers/state_manager.dart';
import '../../../../core/services/shared_preferences.dart';
import '../../../../tools/logging/logger.dart';
import '../../../adverts_plugin/modules/admobs/rewarded/rewarded_ad.dart';
import '../question_module/question_module.dart';
import '../rewards_module/rewards_module.dart';
import 'config/gameplaymodule_config.dart';

class GamePlayModule extends ModuleBase {
  static final Logger _log = Logger(); // ✅ Use a static logger for static methods

  final ServicesManager _servicesManager;
  final ModuleManager _moduleManager;
  final SharedPrefManager? _sharedPref;
  final MainHelperModule? _mainHelperModule;

  /// ✅ No-argument constructor
  GamePlayModule()
      : _moduleManager = ModuleManager(),
        _servicesManager = ServicesManager(),
        _sharedPref = ServicesManager().getService<SharedPrefManager>('shared_pref'),
        _mainHelperModule =
        ModuleManager().getLatestModule<MainHelperModule>(),
        super("game_play_module") {
    _log.info('📢 GamePlayModule initialized and auto-registered.');
  }

  Map<String, dynamic>? question;
  bool isLoading = true;
  String feedbackMessage = "";
  List<String> imageOptions = []; // ✅ Store shuffled images

  Future<void> resetState() async {
    final stateManager = Provider.of<StateManager>(AppManager.globalContext, listen: false);

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
  Future<void> roundInit(Function updateState) async {
    final stateManager = Provider.of<StateManager>(AppManager.globalContext, listen: false);
    final sharedPref = _servicesManager.getService('shared_pref');

    if (sharedPref == null) {
      _log.error("❌ SharedPrefManager not found!");
      return;
    }

    final questionModule = ModuleManager().getLatestModule<QuestionModule>();

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
      final rewardedAdModule = ModuleManager().getLatestModule<RewardedAdModule>();
      final mainHelper = ModuleManager().getLatestModule<MainHelperModule>();

      if (rewardedAdModule != null && mainHelper != null) {
        mainHelper.pauseTimer(); // ✅ Pause timer for ad

        rewardedAdModule.showAd(
          onUserEarnedReward: () => Logger().info("Advert Played."),
          onAdDismissed: () {
            Future.delayed(const Duration(milliseconds: 500), () {
              mainHelper.resumeTimer(() {
                Logger().info("⏳ Timer resumed after ad.");
              });
            });
          },
        );

      } else {
        Logger().info("❌ RewardedAdModule or MainHelperModule not found!");
      }
    }

    await resetState();  // ✅ Ensure state resets before fetching new data

    try {
      // ✅ Get user's level and category from SharedPreferences
      final category = await sharedPref.callServiceMethod('getString', ['category']) ?? "mixed";
      final int level = await sharedPref.callServiceMethod('getInt', ['level_$category']) ?? 1;

      _log.info("🏆 User category: $category | Level: $level");

      final guessedKey = "guessed_${category}_level$level";
      List<String> guessedNames = await sharedPref.callServiceMethod('getStringList', [guessedKey]) ?? [];

// ✅ Log before sending request
      _log.info("📜 Final guessed names sent to backend: $guessedNames");

      // ✅ Fetch question with updated guessed list
      final response = await questionModule.getQuestion(level, category, guessedNames);

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

  Future<void> setTimer(Function onTimeout) async {
    final sharedPref = _servicesManager.getService('shared_pref');

    if (sharedPref == null) {
      _log.error("❌ SharedPrefManager not found!");
      return;
    }

    try {
      // ✅ Get user's level
      final int level = await sharedPref.callServiceMethod('getInt', ['level']) ?? 1;

      // ✅ Don't set a timer if level is 2 or less
      if (level <= 2) {
        _log.info("⏳ Skipping timer. Level is $level.");
        return;
      }

      // ✅ Get the corresponding timer duration for the level (default to 10s if not set)
      final int duration = (GamePlayConfig.levelTimers[level] ?? 10).toInt();

      _log.info("⏳ Starting timer for Level $level: $duration seconds");

      final stateManager = Provider.of<StateManager>(AppManager.globalContext, listen: false);

      // ✅ Update the game timer state before starting
      stateManager.updatePluginState("game_timer", {
        "isRunning": true,
        "duration": duration,
      });

      // ✅ Start timer with dynamic duration
      _mainHelperModule?.startTimer(duration, () {
        _log.info("⏰ Timer finished! Triggering timeout answer.");

        // ✅ Update state when timer stops
        stateManager.updatePluginState("game_timer", {
          "isRunning": false,
          "duration": 0,
        });

        onTimeout(); // ✅ Now directly calls _handleAnswer from GameScreen
      });

    } catch (e) {
      _log.error("❌ Failed to start timer: $e", error: e);
    }
  }

  void checkAnswer(String selectedImage, Function updateState, {bool timeUp = false}) async {
    _log.info("🏆 Checking answer...");

    final correctImage = question?['image_url'] ?? "";
    final rewardsModule = ModuleManager().getLatestModule<RewardsModule>();
    final stateManager = Provider.of<StateManager>(AppManager.globalContext, listen: false);

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
      int points = await rewardsModule.getPoints(pointsKey, category, level);

      _log.forceLog("📌 hint: $points ");

      // ✅ Call saveReward with all necessary data
      final rewardData = await rewardsModule.saveReward(
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
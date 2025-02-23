import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../../../core/00_base/screen_base.dart';
import '../../../../core/managers/app_manager.dart';
import '../../../../core/managers/module_manager.dart';
import '../../../../core/managers/services_manager.dart';
import '../../../../core/managers/state_manager.dart';
import '../../../../core/services/shared_preferences.dart';
import '../../../../tools/logging/logger.dart';
import '../../../adverts_plugin/modules/admobs/rewarded/rewarded_ad.dart';
import '../../../main_plugin/modules/main_helper_module/main_helper_module.dart';
import '../../modules/game_play_module/config/gameplaymodule_config.dart';
import '../../modules/game_play_module/game_play_module.dart';
import 'components/fact_box.dart';
import 'components/feedback_message.dart';
import 'components/game_image_grid.dart';
import 'components/screen_overlay.dart';
import 'components/timer_component.dart';

class GameScreen extends BaseScreen {
  const GameScreen({Key? key}) : super(key: key);

  @override
  String computeTitle(BuildContext context) {
    return "Guess Who";
  }

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends BaseScreenState<GameScreen> {
  static final Logger _log = Logger(); // ✅ Use a static logger for logging

  late final ModuleManager _moduleManager;
  late final ServicesManager _servicesManager;
  late final SharedPrefManager? _sharedPref;
  late final StateManager _stateManager;
  late final GamePlayModule? _gamePlayModule;
  late final MainHelperModule? _mainHelperModule;
  late final RewardedAdModule? _rewardedAdModule;

  bool _showFeedback = false;
  String _feedbackText = "";
  String _correctName = "";
  Timer? _feedbackTimer;
  int _level = 1;
  int _points = 0;
  String _backgroundImage = "";
  final Random _random = Random();
  Set<String> fadedImages = {}; // ✅ Tracks faded images
  CachedNetworkImageProvider? _cachedSelectedImage;

  @override
  void initState() {
    super.initState();
    _log.info("Initializing GameScreen...");

    // ✅ Retrieve managers and modules via Provider
    _moduleManager = Provider.of<ModuleManager>(context, listen: false);
    _servicesManager = Provider.of<ServicesManager>(context, listen: false);
    _stateManager = Provider.of<StateManager>(context, listen: false);

    _sharedPref = _servicesManager.getService<SharedPrefManager>();
    _gamePlayModule = _moduleManager.getLatestModule<GamePlayModule>();
    _mainHelperModule = _moduleManager.getLatestModule<MainHelperModule>();
    _rewardedAdModule = _moduleManager.getLatestModule<RewardedAdModule>();

    _initializeGame();
    _loadLevelAndPoints();
  }

  void _onImagesLoaded() {
    _log.info("🖼️ ALL images loaded. Updating game state...");

    _stateManager.updatePluginState("game_round", {
      "imagesLoaded": true,
    }, force: true);
  }

  void _onFactsLoaded() {
    _stateManager.updatePluginState("game_round", {
      "factLoaded": true,
    }, force: true);
  }

  bool get _isOverlayVisible {
    return context.select<StateManager, bool>((stateManager) {
      final gameRoundState = stateManager.getPluginState<Map<String, dynamic>>("game_round") ?? {};
      return !(gameRoundState["imagesLoaded"] == true && gameRoundState["factLoaded"] == true);
    });
  }

  /// ✅ Handles "Help" button click with Rewarded Ad
  void _useHelp() {
    if (_rewardedAdModule != null && _mainHelperModule != null) {
      _mainHelperModule!.pauseTimer(context); // ✅ Pause timer when ad starts

      _stateManager.updatePluginState("game_round", {
        "hint": true,
      });

      _rewardedAdModule!.showAd(
        context, // ✅ Pass context as the first argument
        onUserEarnedReward: _fadeOutIncorrectImage,
        onAdDismissed: () {
          Future.delayed(const Duration(milliseconds: 500), () {
            _mainHelperModule!.resumeTimer(context, () {
              _log.info("⏳ Timer resumed after ad was closed.");
            });
          });
        },
      );

    } else {
      _log.info("❌ RewardedAdModule or MainHelperModule not found!");
    }
  }

  void _fadeOutIncorrectImage() {
    if (_correctAnswer == null) return;

    List<String> incorrectImages = _gamePlayModule?.imageOptions
        .where((img) => img != _correctAnswer && !fadedImages.contains(img))
        .toList() ??
        [];

    if (incorrectImages.isNotEmpty) {
      String fadedImage = incorrectImages[_random.nextInt(incorrectImages.length)];

      setState(() {
        fadedImages = Set.from(fadedImages)..add(fadedImage);
      });

      _log.info("🚫 An incorrect image has been faded out: $fadedImage");
    }
  }

  Future<void> _loadLevelAndPoints() async {
    if (_sharedPref == null) {
      _log.error('❌ SharedPreferences service not available.');
      return;
    }

    final String category = _sharedPref!.getString('category') ?? "Mixed";
    final int level = _sharedPref!.getInt('level_$category') ?? 1;
    int categoryPoints = 0;

    final int maxLevels = _sharedPref!.getInt('max_levels_$category') ?? 1;

    for (int lvl = 1; lvl <= maxLevels; lvl++) {
      int points = _sharedPref!.getInt('points_${category}_level$lvl') ?? 0;
      categoryPoints += points;
    }

    setState(() {
      _level = level;
      _points = categoryPoints;
    });

    _log.info("📊 Current Category: $category | Level: $_level | Points in Category: $_points");
  }

  void _initializeGame() {
    if (_gamePlayModule == null) {
      Logger().error("❌ GamePlayModule is not initialized!");
      return; // ✅ Prevent crashing
    }

    Logger().info("🔄 Initializing new game round...");

    final stateManager = Provider.of<StateManager>(context, listen: false);
    final gameRoundState = stateManager.getPluginState<Map<String, dynamic>>("game_round") ?? {};

    bool levelUp = gameRoundState["levelUp"] ?? false;
    bool endGame = gameRoundState["endGame"] ?? false;

    if (levelUp || endGame) {
      Logger().info("🚀 Redirecting to Level-Up Screen! LevelUp: $levelUp | EndGame: $endGame");

      // ✅ Navigate to Level-Up Screen with arguments
      Navigator.pushReplacementNamed(
        context,
        "/level-up",
        arguments: {"levelUp": levelUp, "endGame": endGame},
      );

      // ✅ Reset state to prevent looping
      stateManager.updatePluginState("game_round", {
        "levelUp": false,
        "endGame": false,
      }, force: true);

      return; // ✅ Stop further execution of game logic
    }

    _setRandomBackground();

    // ✅ Clear game state BEFORE setting new data
    setState(() {
      _correctAnswer = null;
      fadedImages.clear();
      _gamePlayModule?.imageOptions = []; // ✅ Ensure images reset
    });

    // ✅ Defer state update to the next frame to avoid "setState during build" error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      stateManager.updatePluginState("game_round", {
        "hint": false,
        "imagesLoaded": false,
        "factLoaded": false,
      }, force: true);
    });

    // ✅ Clear the fact box content before loading new facts
    setState(() {
      _gamePlayModule?.question = null;
    });

    Future.delayed(const Duration(milliseconds: 100), () async {
      await _gamePlayModule?.roundInit(context, () {  // ✅ Pass context here
        setState(() {
          _correctAnswer = _gamePlayModule?.question?['image_url'];
          _gamePlayModule?.imageOptions = [
            _gamePlayModule?.question?['image_url'],
            ..._gamePlayModule?.question?['distractor_images']
          ];
          _gamePlayModule?.imageOptions.shuffle(Random());
        });
      });

      Logger().info("🔹 after round init ${_gamePlayModule?.question}");

// ✅ Pass context to setTimer
      _gamePlayModule?.setTimer(context, () {
        _handleAnswer("", timeUp: true);
      });


      Logger().info("✅ New game round initialized!");
    });

  }

  String? _correctAnswer; // ✅ Stores the correct answer dynamically

  void _handleAnswer(String selectedImage, {bool timeUp = false}) {

    /// ✅ Fetch Cached Image
    CachedNetworkImageProvider cachedImageProvider = CachedNetworkImageProvider(selectedImage);

// ✅ Pass context to checkAnswer
    _gamePlayModule?.checkAnswer(context, selectedImage, () {
      setState(() {
        _correctAnswer = selectedImage;
      });

      Logger().info("🔹 Correct answer $_correctAnswer");

      _updateFeedbackState(
        showFeedback: true,
        feedbackText: _gamePlayModule!.feedbackMessage,
        cachedImage: cachedImageProvider, // ✅ Pass Cached Image
        correctName: _gamePlayModule?.question?['actor'],
      );

      _loadLevelAndPoints();
    }, timeUp: timeUp);

  }

  /// ✅ Select a new random background
  void _setRandomBackground() {
    setState(() {
      _backgroundImage = MainHelperModule.getRandomBackground();
    });
    Logger().info("🎨 New Background: $_backgroundImage");
  }

  void _updateFeedbackState({required bool showFeedback, String feedbackText = "", CachedNetworkImageProvider? cachedImage, String correctName = ""}) {
    setState(() {
      _showFeedback = showFeedback;
      _feedbackText = feedbackText;
      _cachedSelectedImage = cachedImage; // ✅ Store Cached Image
      _correctName = correctName;
    });

    if (showFeedback) {
      _feedbackTimer?.cancel();
      _feedbackTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          _closeFeedback();
        }
      });
    }
  }

  void _closeFeedback() {
    _updateFeedbackState(showFeedback: false);
    _feedbackTimer?.cancel();

    setState(() {
      fadedImages.clear(); // ✅ Clear faded images
    });

    _initializeGame(); // ✅ Reset game and change background
  }

  @override
  Widget buildContent(BuildContext context) {
    return Stack(
      children: [
        // ✅ Background Image
        Positioned.fill(
          child: _backgroundImage.isNotEmpty
              ? Image.asset(_backgroundImage, fit: BoxFit.cover)
              : Container(color: Colors.black),
        ),

        SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ Top bar with Level, TimerBar, and Points
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("⭐ Category Level: $_level",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("🏆 Points: $_points",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Consumer<StateManager>(
                      builder: (context, stateManager, child) {
                        final timerState =
                            stateManager.getPluginState<Map<String, dynamic>>("game_timer") ?? {};
                        final isRunning = timerState["isRunning"] ?? false;
                        final duration = (timerState["duration"] ?? 0).toDouble();
                        final int currentLevel = _level > 0 ? _level : 1;
                        final double levelTimer =
                        (GamePlayConfig.levelTimers[currentLevel] ?? 10).toDouble();
                        return isRunning
                            ? Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: TimerBar(remainingTime: duration, totalDuration: levelTimer),
                          ),
                        )
                            : const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),

              GameImageGrid(
                imageOptions: _gamePlayModule?.imageOptions?.map((e) => e.toString()).toList() ?? [], // ✅ Prevent null
                onImageTap: _handleAnswer,
                fadedImages: fadedImages,
                onAllImagesLoaded: _onImagesLoaded, // ✅ Call when images are loaded
              ),


              const SizedBox(height: 20),

              // ✅ Help Button (Center-aligned)
              ElevatedButton(
                onPressed: _useHelp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                child: const Text("💡 Use Help", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 20),

              FactBox(
                facts: (_gamePlayModule?.question?['facts'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                    [], // ✅ Ensure facts is never null
                onFactsLoaded: _onFactsLoaded,
              ),

            ],
          ),
        ),

        // ✅ Full-Screen Feedback Overlay
        if (_showFeedback)
          Positioned.fill(
            child: FeedbackMessage(
              feedback: _feedbackText,
              onClose: _closeFeedback,
              cachedImage: _cachedSelectedImage,
              correctName: _correctName, // ✅ Pass Cached Image
            ),
          ),

        // ✅ Full-Screen Loading Overlay
        const ScreenOverlay(), // ✅ New External Component
      ],
    );
  }


}
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../../../../core/managers/module_manager.dart';
import '../../../../../utils/consts/theme_consts.dart';

class FeedbackMessage extends StatefulWidget {
  final String feedback;
  final String correctName;
  final VoidCallback onClose;
  final String? selectedImageUrl;
  final CachedNetworkImageProvider? cachedImage;
  final String currentCategory;
  final int currentLevel;


  const FeedbackMessage({
    Key? key,
    required this.feedback,
    required this.correctName,
    required this.onClose,
    this.selectedImageUrl,
    this.cachedImage,
    required this.currentCategory,
    required this.currentLevel,

  }) : super(key: key);

  @override
  _FeedbackMessageState createState() => _FeedbackMessageState();
}

class _FeedbackMessageState extends State<FeedbackMessage> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    if (widget.feedback.contains("Correct")) {
      _confettiController.play();
    }
  }

  String _formatCorrectName(String name) {
    return name
        .replaceAll("_", " ") // ✅ Replace underscores with spaces
        .split(" ") // ✅ Split into words
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : "") // ✅ Capitalize first letter of each word
        .join(" "); // ✅ Join words back into a single string
  }


  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isCorrect = widget.feedback.contains("Correct");
    String safeCategory = widget.currentCategory.isNotEmpty ? widget.currentCategory : "default";
    int safeLevel = widget.currentLevel > 0 ? widget.currentLevel : 1;

    // Construct the background image paths
    String backgroundImagePath = widget.currentCategory.isNotEmpty
        ? 'assets/images/backgrounds/lev$safeLevel/$safeCategory/main_background_$safeCategory.png'
        : 'assets/images/backgrounds/main_background_default.png';

    String backgroundImageOverlayPath = widget.currentCategory.isNotEmpty
        ? 'assets/images/backgrounds/lev$safeLevel/$safeCategory/main_background_overlay_$safeCategory.png'
        : 'assets/images/backgrounds/main_background_overlay_default.png';

    return Stack(
      alignment: Alignment.center,
      children: [
        if (isCorrect) ...[
          // ✅ Full-Screen Background
          Positioned.fill(
            child: Image.asset(
              backgroundImagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // ✅ Cached Celeb Image (Centered)
          Align(
            alignment: Alignment.center,
            child: FractionallySizedBox(
              widthFactor: 0.2, // ✅ 10% of the screen width
              child: Image(
                image: widget.cachedImage!,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // ✅ Full-Screen Overlay
          Positioned.fill(
            child: Image.asset(
              backgroundImageOverlayPath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ] else ...[
          // ❌ Black Half-Opacity Background (Only if incorrect)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.8),
            ),
          ),
        ],

        // ✅ Name/Message Section (Always at the Top)
        Positioned(
          top: MediaQuery.of(context).size.height * 0.15, // ✅ Push to top
          left: 0,
          right: 0,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  widget.feedback,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? AppColors.accentColor : Colors.redAccent,
                  ),
                ),
              ),

              if (isCorrect)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _formatCorrectName(widget.correctName),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // ✅ Close Button (Always at the Very Bottom)
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.05, // ✅ Push to bottom
          left: 0,
          right: 0,
          child: Center(
            child: ElevatedButton(
              onPressed: widget.onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              child: const Text("Close", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ),

        // ✅ Confetti Animation (Only if Correct)
        if (isCorrect)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.20, // ✅ 1/4 from the top
            left: 0,
            right: 0,  // ✅ Ensures full width for centering
            child: Align(
              alignment: Alignment.topCenter,  // ✅ Center it horizontally
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.15,
                numberOfParticles: 15,
                maxBlastForce: 20,
                minBlastForce: 10,
                gravity: 0.1,
              ),
            ),
          ),
      ],
    );


  }

}

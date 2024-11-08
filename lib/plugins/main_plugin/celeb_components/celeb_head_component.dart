import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state_provider.dart';
import '../main_plugin_main.dart';
import '../functions/animation_helper.dart';

class CelebHeadComponent extends StatefulWidget {
  final String id; // Unique ID for this component

  const CelebHeadComponent({Key? key, required this.id}) : super(key: key);

  @override
  _CelebHeadComponentState createState() => _CelebHeadComponentState();
}

class _CelebHeadComponentState extends State<CelebHeadComponent> with TickerProviderStateMixin {
  late AnimationController _controller;
  late String celebImgUrl;

  @override
  void initState() {
    super.initState();
    celebImgUrl = 'assets/app_images/default_celeb_head.png';

    // Initialize and register the controller with AnimationManager
    _controller = AnimationHelper.initController(
      vsync: this,
      id: widget.id,
      duration: const Duration(seconds: 2),
    );

    // Start the animation immediately to ensure it's running
    _controller.repeat(reverse: true);

  }

  @override
  void dispose() {
    // Unregister the controller from AnimationManager
    AnimationManager.removeController(widget.id);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimationHelper.bounce(
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: celebImgUrl.startsWith('http')
                ? NetworkImage(celebImgUrl)
                : AssetImage(celebImgUrl) as ImageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      controller: _controller,
    );
  }
}

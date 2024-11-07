import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state_provider.dart';
import '../main_plugin_main.dart';

class CelebHeadComponent extends StatelessWidget {
  const CelebHeadComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appStateProvider = Provider.of<AppStateProvider>(context);
    final pluginStateKey = "${MainPlugin().runtimeType}State";
    final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};

    final celebImgUrl = pluginState['celeb_img_url'] ?? 'assets/app_images/default_celeb_head.png';

    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: celebImgUrl.startsWith('http')
                ? NetworkImage(celebImgUrl)
                : AssetImage(celebImgUrl) as ImageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

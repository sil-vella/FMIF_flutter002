import 'package:flush_me_im_famous/plugins/adverts_plugin/modules/admobs/banner/banner_ad.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../tools/logging/logger.dart';
import '../managers/app_manager.dart';
import '../managers/module_manager.dart';
import '../managers/navigation_manager.dart';
import '../../utils/consts/config.dart';
import '../../utils/consts/theme_consts.dart';

abstract class BaseScreen extends StatefulWidget {
  const BaseScreen({Key? key}) : super(key: key);

  /// Define a method to compute the title dynamically
  String computeTitle(BuildContext context);

  @override
  BaseScreenState createState();
}

abstract class BaseScreenState<T extends BaseScreen> extends State<T> {
  late final AppManager appManager;
  final ModuleManager _moduleManager = ModuleManager();

  final Logger log = Logger();
  BannerAdModule? bannerAdModule;

  @override
  void initState() {
    super.initState();

    appManager = Provider.of<AppManager>(context, listen: false);
    bannerAdModule = _moduleManager.getLatestModule<BannerAdModule>();

    if (bannerAdModule != null) {
      bannerAdModule!.loadBannerAd(Config.admobsTopBanner);
      bannerAdModule!.loadBannerAd(Config.admobsBottomBanner);
      log.info('✅ Banner Ads preloaded.');
    } else {
      log.error("❌ BannerAdModule not found.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationManager = Provider.of<NavigationManager>(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.computeTitle(context),
          style: AppTextStyles.headingMedium(color: AppColors.darkGray),
        ),
        backgroundColor: AppColors.accentColor,
        iconTheme: IconThemeData(color: AppColors.darkGray),
      ),

      drawer: Drawer(
        child: Container(
          color: AppColors.scaffoldBackgroundColor,
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: AppColors.accentColor),
                child: Center(
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ...navigationManager.routes.map((route) => ListTile(
                leading: Icon(Icons.circle, color: AppColors.accentColor),
                title: Text(route.path.replaceAll("/", "")),
                onTap: () {
                  Navigator.pop(context);
                  context.go(route.path); // ✅ Use GoRouter navigation
                },
              )),
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          if (bannerAdModule != null)
            Container(
              height: 50,
              alignment: Alignment.center,
              color: Colors.black,
              child: bannerAdModule!.getBannerWidget(context, Config.admobsTopBanner),
            ),

          Expanded(child: buildContent(context)),

          if (bannerAdModule != null)
            Container(
              height: 50,
              alignment: Alignment.center,
              color: Colors.black,
              child: bannerAdModule!.getBannerWidget(context, Config.admobsBottomBanner),
            ),
        ],
      ),
    );
  }

  /// Abstract method to be implemented in subclasses
  Widget buildContent(BuildContext context);
}

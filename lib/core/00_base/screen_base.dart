import 'package:flush_me_im_famous/plugins/adverts_plugin/modules/admobs/banner/banner_ad.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../tools/logging/logger.dart';
import '../managers/app_manager.dart';
import '../managers/module_manager.dart';
import '../managers/navigation_manager.dart';
import '../../utils/consts/config.dart'; // ✅ Import AdMob Config
import '../../utils/consts/theme_consts.dart'; // ✅ Import Theme Constants

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

  // ✅ Define logger instance
  final Logger log = Logger();
  BannerAdModule? bannerAdModule; // ✅ Store instance

  @override
  void initState() {
    super.initState();

    // ✅ Retrieve AppManager from Provider
    appManager = Provider.of<AppManager>(context, listen: false);

    // ✅ Fetch the latest BannerAdModule
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
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor, // ✅ Apply Themed Background
      appBar: AppBar(
        title: Text(
          widget.computeTitle(context),
          style: AppTextStyles.headingMedium(color: AppColors.darkGray), // ✅ Dark Gray Title
        ),
        backgroundColor: AppColors.accentColor, // ✅ Themed Gold Background
        iconTheme: IconThemeData(color: AppColors.darkGray), // ✅ Change Burger Menu Color
      ),

      drawer: Drawer(
        child: Container(
          color: AppColors.scaffoldBackgroundColor, // ✅ Themed Drawer Background
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: AppColors.accentColor, // ✅ Themed Primary Color
                ),
                child: Center(
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      color: AppColors.primaryColor, // ✅ Themed Text Color
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ...Provider.of<NavigationContainer>(context, listen: false)
                  .drawerItems
                  .map(
                    (item) => ListTile(
                  leading: Icon(item.icon, color: AppColors.accentColor), // ✅ Themed Icon
                  title: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, item.route);
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          // ✅ Top Banner Ad (Ensure Unique Key)
          if (bannerAdModule != null)
            Container(
              height: 50,
              alignment: Alignment.center,
              color: Colors.black,
              child: bannerAdModule!.getBannerWidget(
                Config.admobsTopBanner,
                context,
                widgetKey: 'topBanner_${UniqueKey().toString()}', // 🔥 Unique Key
              ) ?? const SizedBox(),
            ),

          // ✅ Main Content
          Expanded(
            child: buildContent(context),
          ),

          // ✅ Bottom Banner Ad (Ensure Unique Key)
          if (bannerAdModule != null)
            Container(
              height: 50,
              alignment: Alignment.center,
              color: Colors.black,
              child: bannerAdModule!.getBannerWidget(
                Config.admobsBottomBanner,
                context,
                widgetKey: 'bottomBanner_${UniqueKey().toString()}', // 🔥 Unique Key
              ) ?? const SizedBox(),
            ),
        ],
      ),

    );
  }

  /// Abstract method to be implemented in subclasses
  Widget buildContent(BuildContext context);
}

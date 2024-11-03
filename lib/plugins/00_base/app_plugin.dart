// plugins/base/app_plugin.dart
import 'package:flutter/material.dart';

abstract class AppPlugin {
  void initialize(BuildContext context);
  void onStartup(); // Add onStartup method for startup actions
}

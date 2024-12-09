import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/app_state_provider.dart';
import '../../../api/modules/connection_module.dart';

class UserUpdateModule {
  final ConnectionModule connectionModule;

  UserUpdateModule({required this.connectionModule});

  /// Updates the user's points in the database
  Future<Map<String, dynamic>> updatePoints({
    required String username,
    required int points,
    required BuildContext context,
  }) async {
    dev.log("Starting updatePoints with username: $username, points: $points");

    try {
      dev.log("Sending POST request to /update-points");
      final response = await connectionModule.sendPostRequest(
        '/update-points',
        {'username': username, 'points': points},
      );
      dev.log("Response from /update-points: $response");

      if (response['success'] == true) {
        dev.log("Update points successful. Updating plugin state.");

        // Update the user's points in the plugin state
        final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
        await appStateProvider.updatePluginState("LoginPluginState", {
          "points": response['updated_points'], // Update with the new points
        });

        dev.log("Plugin state updated with new points: ${response['updated_points']}");

        return {
          'success': true,
          'updated_points': response['updated_points'],
        };
      } else {
        dev.log("Failed to update points. Message: ${response['message'] ?? 'Unknown error'}");
        return {
          'success': false,
          'message': response['message'] ?? 'An error occurred',
        };
      }
    } catch (error, stackTrace) {
      dev.log("Error in updatePoints: $error", stackTrace: stackTrace);
      return {
        'success': false,
        'message': 'An exception occurred while updating points.',
      };
    }
  }

  /// Updates the user's guessed celebrity and category in the database
  Future<Map<String, dynamic>> updateGuessed({
    required String username,
    required String guessedName,
    required String guessedCategory,
    required BuildContext context,
  }) async {
    dev.log("Starting updateGuessed with username: $username, guessedName: $guessedName, guessedCategory: $guessedCategory");

    try {
      dev.log("Sending POST request to /update-guessed");
      final response = await connectionModule.sendPostRequest(
        '/update-guessed',
        {
          'username': username,
          'guessed_name': guessedName,
          'guessed_category': guessedCategory,
        },
      );
      dev.log("Response from /update-guessed: $response");

      if (response['success'] == true) {
        dev.log("Update guessed successful. Updating plugin state.");

        // Update the guessed name and category in the plugin state
        final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
        await appStateProvider.updatePluginState("LoginPluginState", {
          "guessed_name": guessedName, // Update with the guessed name
          "guessed_category": guessedCategory, // Update with the guessed category
        });

        dev.log("Plugin state updated with new guessed name and category");

        return {
          'success': true,
          'guessed_name': guessedName,
          'guessed_category': guessedCategory,
        };
      } else {
        dev.log("Failed to update guessed. Message: ${response['message'] ?? 'Unknown error'}");
        return {
          'success': false,
          'message': response['message'] ?? 'An error occurred',
        };
      }
    } catch (error, stackTrace) {
      dev.log("Error in updateGuessed: $error", stackTrace: stackTrace);
      return {
        'success': false,
        'message': 'An exception occurred while updating guessed.',
      };
    }
  }
}

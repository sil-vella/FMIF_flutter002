import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state_provider.dart';

class AudioHelper {
  // Singleton instance
  static final AudioHelper _instance = AudioHelper._internal();

  factory AudioHelper() {
    return _instance;
  }

  AudioHelper._internal();

  final AudioPlayer _backgroundPlayer = AudioPlayer();
  final List<AudioPlayer> _effectPlayers = [];
  double _globalVolume = 0.5;

  /// Plays background sound with looping
  Future<void> playBackgroundSound({
    required String audioPath,
    required BuildContext context,
  }) async {
    try {
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);

      final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
      final isMuted = appStateProvider.getPluginState("MainPluginState")?["sound_muted"] ?? false;

      await _backgroundPlayer.play(
        AssetSource(audioPath),
        volume: isMuted ? 0.0 : _globalVolume,
      );
    } catch (e) {
      print("Error playing background sound: $e");
    }
  }

  /// Updates the volume dynamically based on the plugin state
  void updateVolumeBasedOnState(BuildContext context) {
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    final isMuted = appStateProvider.getPluginState("MainPluginState")?["sound_muted"] ?? false;

    _backgroundPlayer.setVolume(isMuted ? 0.0 : _globalVolume);
  }

  /// Sets the global volume for all sounds
  void setGlobalVolume(double volume) {
    _globalVolume = volume.clamp(0.0, 1.0);
    _backgroundPlayer.setVolume(_globalVolume);

    for (final effectPlayer in _effectPlayers) {
      effectPlayer.setVolume(_globalVolume);
    }
  }

  /// Plays a one-time sound effect and disposes it after playback, respecting mute state
  Future<void> playEffectSound(String audioPath, BuildContext context) async {
    try {
      final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
      final isMuted = appStateProvider.getPluginState("MainPluginState")?["sound_muted"] ?? false;

      final effectPlayer = AudioPlayer();
      _effectPlayers.add(effectPlayer);

      await effectPlayer.play(
        AssetSource(audioPath),
        volume: isMuted ? 0.0 : _globalVolume, // Respect mute state
      );

      effectPlayer.onPlayerComplete.listen((_) {
        _effectPlayers.remove(effectPlayer);
        effectPlayer.dispose();
      });
    } catch (e) {
      print("Error playing effect sound: $e");
    }
  }

  /// Stops background sound but keeps the player ready
  void stopBackgroundSound() {
    _backgroundPlayer.stop();
  }

  /// Disposes all audio resources
  void dispose() {
    print("Disposing AudioHelper resources...");
    _backgroundPlayer.dispose();

    for (final effectPlayer in _effectPlayers) {
      effectPlayer.dispose();
    }
    _effectPlayers.clear();
  }
}

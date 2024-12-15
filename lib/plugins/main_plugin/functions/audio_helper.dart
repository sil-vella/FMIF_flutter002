import 'dart:developer';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/providers/app_state_provider.dart';

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

  List<String> _backgroundPlaylist = [];
  int _currentTrackIndex = 0;

  /// Map of available audio files
  final Map<String, String> correctAfter = {
    "aftermath_1": "audio/aftermath-001.mp3",
    "aftermath_2": "audio/aftermath-002.mp3",
    "aftermath_3": "audio/aftermath-003.mp3",
    "skibidi": "audio/aftermath-004-skibidi.mp3",
  };

  final Map<String, String> incorrectAfter = {
    "aftermath_rocket_001": "audio/aftermath_rocket_001.mp3",
    "aftermath_wings_001": "audio/aftermath_wings_001.mp3",
  };

  final Map<String, String> applauseFiles = {
    "applause_1": "audio/applause_pt_1_002.mp3",
    "applause_2": "audio/applause_pt_2_002.mp3",
  };

  /// Plays a playlist of background sounds in sequence
  Future<void> playBackgroundPlaylist({
    required List<String> audioPaths,
    required BuildContext context,
  }) async {
    try {
      _backgroundPlaylist = audioPaths;
      _currentTrackIndex = 0;

      if (_backgroundPlaylist.isNotEmpty) {
        await _playCurrentTrack(context);
      }
    } catch (e) {
      log('Error: $e');
    }
  }

  Future<void> _playCurrentTrack(BuildContext context) async {
    try {
      if (_currentTrackIndex < _backgroundPlaylist.length) {
        final currentTrack = _backgroundPlaylist[_currentTrackIndex];

        final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
        final isMuted = appStateProvider.getPluginState("MainPluginState")?["sound_muted"] ?? false;

        await _backgroundPlayer.setReleaseMode(ReleaseMode.stop);
        await _backgroundPlayer.play(
          AssetSource(currentTrack),
          volume: isMuted ? 0.0 : _globalVolume,
        );

        _backgroundPlayer.onPlayerComplete.listen((_) async {
          _currentTrackIndex++;
          if (_currentTrackIndex < _backgroundPlaylist.length) {
            await _playCurrentTrack(context); // Play the next track
          } else {
            // Restart the playlist (loop)
            _currentTrackIndex = 0;
            await _playCurrentTrack(context);
          }
        });
      }
    } catch (e) {
      log('Error: $e');
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
      log('Error details: $e');
    }
  }

  /// Fades out all currently playing effect sounds
  void fadeOutAndStopEffectSounds() {
    for (final effectPlayer in _effectPlayers) {
      _fadeOutPlayer(effectPlayer);
    }
  }

  /// Fades out an individual player
  void _fadeOutPlayer(AudioPlayer player) {
    double fadeVolume = _globalVolume;
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (fadeVolume > 0) {
        fadeVolume -= 0.05; // Gradual decrease
        player.setVolume(fadeVolume.clamp(0.0, 1.0));
      } else {
        timer.cancel();
        player.stop();
        _effectPlayers.remove(player);
        player.dispose();
      }
    });
  }

  /// Resets the global volume for all future playbacks
  void resetGlobalVolume() {
    _globalVolume = 0.5;
  }

  /// Stops background sound but keeps the player ready
  void stopBackgroundSound() {
    _backgroundPlayer.stop();
  }

  /// Disposes all audio resources
  void dispose() {
    _backgroundPlayer.dispose();

    for (final effectPlayer in _effectPlayers) {
      effectPlayer.dispose();
    }
    _effectPlayers.clear();
  }
}

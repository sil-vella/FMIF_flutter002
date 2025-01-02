import 'dart:developer' as dev;
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/providers/app_state_provider.dart';

class AudioHelper  {
  static final AudioHelper _instance = AudioHelper._internal();

  factory AudioHelper() => _instance;

  final Map<String, AudioPlayer> _audioPlayers = {};
  final Map<String, AudioPlayer> _preloadedPlayers = {};
  final Random _random = Random();

  AudioHelper._internal();

  final Map<String, String> backgroundSounds = {
    "backsound_1": "audio/background002.mp3",
  };

  /// Timer sound list
  final Map<String, String> timerSounds = {
    "ticking": "audio/ticking_timer003.mp3",
    "time_up": "audio/time_up.mp3",
  };

  /// Map of available audio files
  final Map<String, String> correctSounds = {
    "correct_1": "audio/correct_chime001.mp3",
  };

  /// Map of available audio files
  final Map<String, String> incorrectSounds = {
    "incorrect_1": "audio/incorrect_chime001.mp3",
  };

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

  final Map<String, String> flushingFiles = {
    "flushing_1": "audio/flush006.mp3",
  };

  /// Play a specific audio file from a provided sound list by key.
  Future<void> playSpecific(BuildContext context, Map<String, String> soundList, String key, {double volume = 1.0}) async {
    try {
      final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
      final isMuted = appStateProvider.getPluginState("MainPluginState")?["sound_muted"] ?? false;

      final filePath = soundList[key];
      if (filePath == null) {
        dev.log('Error: Invalid key "$key" provided.');
        return;
      }

      // Stop the specific sound if already playing
      if (_audioPlayers.containsKey(filePath)) {
        await _audioPlayers[filePath]!.stop();
        _audioPlayers.remove(filePath);
      }

      if (!_audioPlayers.containsKey(filePath)) {
        _audioPlayers[filePath] = AudioPlayer();
      }

      final player = _audioPlayers[filePath]!;
      await player.setVolume(isMuted ? 0.0 : volume);
      await player.play(AssetSource(filePath));
      dev.log('Playing specific audio: $filePath');
    } catch (e) {
      dev.log('Error playing specific audio: $e');
    }
  }

  /// Play a random audio file from the provided sound list.
  Future<void> playFromList(BuildContext context, Map<String, String> soundList, {double volume = 1.0}) async {
    try {
      final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
      final isMuted = appStateProvider.getPluginState("MainPluginState")?["sound_muted"] ?? false;

      if (soundList.isEmpty) {
        dev.log('Error: Sound list is empty.');
        return;
      }

      // Select a random file
      final keys = soundList.keys.toList();
      final randomKey = keys[_random.nextInt(keys.length)];
      final filePath = soundList[randomKey]!;

      // Stop other sounds in the same list
      for (final path in soundList.values) {
        if (_audioPlayers.containsKey(path)) {
          await _audioPlayers[path]!.stop();
          _audioPlayers.remove(path);
        }
      }

      // Play the new random sound
      if (!_audioPlayers.containsKey(filePath)) {
        _audioPlayers[filePath] = AudioPlayer();
      }

      final player = _audioPlayers[filePath]!;
      dev.log('Playing random audio: $filePath');
      await player.setVolume(isMuted ? 0.0 : volume);
      await player.play(AssetSource(filePath));
    } catch (e) {
      dev.log('Error playing random audio: $e');
    }
  }

  /// Play a random audio file in a loop from the provided sound list.
  Future<void> loopSpecific(BuildContext context, Map<String, String> soundList, String key, {double volume = 1.0}) async {
    try {
      final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
      final isMuted = appStateProvider.getPluginState("MainPluginState")?["sound_muted"] ?? false;

      final filePath = soundList[key];
      if (filePath == null) {
        dev.log('Error: Invalid key "$key" provided.');
        return;
      }

      if (!_audioPlayers.containsKey(filePath)) {
        _audioPlayers[filePath] = AudioPlayer();
      }
      final player = _audioPlayers[filePath]!;
      await player.setVolume(isMuted ? 0.0 : volume);
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(AssetSource(filePath));
    } catch (e) {
      dev.log('Error looping audio: $e');
    }
  }

  /// Play a random audio file in a loop from the provided sound list.
  Future<void> loopFromList(BuildContext context, Map<String, String> soundList, {double volume = 1.0}) async {
    try {
      final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
      final isMuted = appStateProvider.getPluginState("MainPluginState")?["sound_muted"] ?? false;

      if (soundList.isEmpty) {
        dev.log('Error: Sound list is empty.');
        return;
      }
      final keys = soundList.keys.toList();
      final randomKey = keys[_random.nextInt(keys.length)];
      final filePath = soundList[randomKey]!;

      if (!_audioPlayers.containsKey(filePath)) {
        _audioPlayers[filePath] = AudioPlayer();
      }
      final player = _audioPlayers[filePath]!;
      await player.setVolume(isMuted ? 0.0 : volume);
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(AssetSource(filePath));
    } catch (e) {
      dev.log('Error looping audio: $e');
    }
  }

  Future<void> playListInOrder(BuildContext context, Map<String, String> soundList, {double volume = 1.0}) async {
    try {
      final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
      final isMuted = appStateProvider.getPluginState("MainPluginState")?["sound_muted"] ?? false;

      if (soundList.isEmpty) {
        dev.log('Error: Sound list is empty.');
        return;
      }

      // Stop other sounds in the list
      for (final path in soundList.values) {
        if (_audioPlayers.containsKey(path)) {
          await _audioPlayers[path]!.stop();
          _audioPlayers.remove(path);
        }
      }

      final files = soundList.values.toList();

      // Loop indefinitely through the sound list
      while (true) {
        for (final filePath in files) {
          if (!_audioPlayers.containsKey(filePath)) {
            _audioPlayers[filePath] = AudioPlayer();
          }

          final player = _audioPlayers[filePath]!;
          dev.log('Playing file in order: $filePath');
          await player.setVolume(isMuted ? 0.0 : volume);
          await player.play(AssetSource(filePath));

          // Wait until the current file finishes playing
          await player.onPlayerComplete.first;
        }
      }
    } catch (e) {
      dev.log('Error playing list in order: $e');
    }
  }


  /// Stop any sound currently playing from a provided sound list.
  Future<void> stopListSounds(Map<String, String> soundList) async {
    try {
      for (final filePath in soundList.values) {
        if (_audioPlayers.containsKey(filePath)) {
          await _audioPlayers[filePath]!.stop();
          _audioPlayers.remove(filePath);
        }
      }
    } catch (e) {
      dev.log('Error stopping sounds from list: $e');
    }
  }

  /// Toggle mute/unmute for all active audio players.
  Future<void> toggleMute(BuildContext context, bool mute) async {
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);

    for (var player in _audioPlayers.values) {
      await player.setVolume(mute ? 0.0 : 1.0); // Set volume to 0.0 for mute, 1.0 for unmute
    }

    // Update the plugin state
    appStateProvider.updatePluginState("MainPluginState", {"sound_muted": mute});

    dev.log(mute ? 'All sounds have been muted.' : 'All sounds have been unmuted.');
  }

      /// Stop a specific sound using a sound list and its key.
  Future<void> stopSound(Map<String, String> soundList, String key) async {
    try {
      final filePath = soundList[key];
      if (filePath == null) {
        dev.log('Error: Invalid key "$key" provided.');
        return;
      }
      if (_audioPlayers.containsKey(filePath)) {
        await _audioPlayers[filePath]!.stop();
        _audioPlayers.remove(filePath);
      }
    } catch (e) {
      dev.log('Error stopping sound: $e');
    }
  }

  /// Preload an audio file using a sound list and its key.
  Future<void> preload(Map<String, String> soundList, String key) async {
    try {
      final filePath = soundList[key];
      if (filePath == null) {
        dev.log('Error: Invalid key "$key" provided.');
        return;
      }
      if (!_preloadedPlayers.containsKey(filePath)) {
        final preloadedPlayer = AudioPlayer();
        await preloadedPlayer.setSource(AssetSource(filePath));
        _preloadedPlayers[filePath] = preloadedPlayer;
      }
    } catch (e) {
      dev.log('Error preloading audio: $e');
    }
  }

  /// Stop all active sounds.
  Future<void> stopAll() async {
    for (var player in _audioPlayers.values) {
      await player.stop();
    }
    _audioPlayers.clear();
  }

  /// Release all resources.
  Future<void> dispose() async {
    for (var player in _audioPlayers.values) {
      await player.dispose();
    }
    for (var player in _preloadedPlayers.values) {
      await player.dispose();
    }
    _audioPlayers.clear();
    _preloadedPlayers.clear();
  }
}

import 'dart:developer' as dev;
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../services/providers/app_state_provider.dart';

class AudioHelper {
  static AudioHelper? _instance;

  factory AudioHelper() {
    if (_instance == null) {
      _instance = AudioHelper._internal();
    }
    return _instance!;
  }

  final Map<String, AudioPlayer> _audioPlayers = {};
  final Map<String, AudioPlayer> _preloadedPlayers = {};
  final Set<String> _currentlyPlaying = {}; // Tracks currently playing audio
  final Random _random = Random();

  AudioHelper._internal();

  final Map<String, String> backgroundSounds = {
    "backsound_1": "assets/audio/background002.mp3",
  };

  final Map<String, String> timerSounds = {
    "ticking": "assets/audio/ticking_timer003.mp3",
    "time_up": "assets/audio/time_up.mp3",
  };

  final Map<String, String> correctSounds = {
    "correct_1": "assets/audio/correct_chime001.mp3",
  };

  final Map<String, String> incorrectSounds = {
    "incorrect_1": "assets/audio/incorrect_chime001.mp3",
  };

  final Map<String, String> correctAfter = {
    "aftermath_1": "assets/audio/aftermath-001.mp3",
    "aftermath_2": "assets/audio/aftermath-002.mp3",
    "aftermath_3": "assets/audio/aftermath-003.mp3",
    "skibidi": "assets/audio/aftermath-004-skibidi.mp3",
  };

  final Map<String, String> incorrectAfter = {
    "aftermath_rocket_001": "assets/audio/aftermath_rocket_001.mp3",
  };

  final Map<String, String> applauseFiles = {
    "applause_1": "assets/audio/applause_pt_1_002.mp3",
    "applause_2": "assets/audio/applause_pt_2_002.mp3",
  };

  final Map<String, String> flushingFiles = {
    "flushing_1": "assets/audio/flush006.mp3",
  };

  static Future<void> removeInstance() async {
    if (_instance != null) {
      await _instance!.dispose();
      _instance = null;
    }
  }

  Future<void> dispose() async {
    for (var player in _audioPlayers.values) {
      await player.dispose();
    }
    for (var player in _preloadedPlayers.values) {
      await player.dispose();
    }
    _audioPlayers.clear();
    _preloadedPlayers.clear();
    _currentlyPlaying.clear();
  }

  Future<void> playSpecific(BuildContext context, Map<String, String> soundList, String key, {double volume = 1.0}) async {
    try {
      final filePath = soundList[key];
      if (filePath == null) {
        dev.log('Error: Invalid key "$key" provided.');
        return;
      }

      if (_currentlyPlaying.contains(filePath)) {
        dev.log('Audio "$filePath" is already playing.');
        return;
      }

      for (final path in soundList.values) {
        if (_currentlyPlaying.contains(path)) {
          await stopSound(soundList, soundList.keys.firstWhere((k) => soundList[k] == path));
        }
      }

      if (!_audioPlayers.containsKey(filePath)) {
        _audioPlayers[filePath] = AudioPlayer();
      }

      final player = _audioPlayers[filePath]!;
      await player.setVolume(volume);
      await player.setAsset(filePath);
      await player.play();

      _currentlyPlaying.add(filePath);

      player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _currentlyPlaying.remove(filePath);
        }
      });

      dev.log('Playing specific audio: $filePath');
    } catch (e) {
      dev.log('Error playing specific audio: $e');
    }
  }

  Future<void> playFromList(BuildContext context, Map<String, String> soundList, {double volume = 1.0}) async {
    try {
      if (soundList.isEmpty) {
        dev.log('Error: Sound list is empty.');
        return;
      }

      for (final path in soundList.values) {
        if (_currentlyPlaying.contains(path)) {
          await stopSound(soundList, soundList.keys.firstWhere((k) => soundList[k] == path));
        }
      }

      final keys = soundList.keys.toList();
      final randomKey = keys[_random.nextInt(keys.length)];
      final filePath = soundList[randomKey]!;

      if (_currentlyPlaying.contains(filePath)) {
        dev.log('Audio "$filePath" is already playing.');
        return;
      }

      if (!_audioPlayers.containsKey(filePath)) {
        _audioPlayers[filePath] = AudioPlayer();
      }

      final player = _audioPlayers[filePath]!;
      await player.setVolume(volume);
      await player.setAsset(filePath);
      await player.play();

      _currentlyPlaying.add(filePath);

      player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _currentlyPlaying.remove(filePath);
        }
      });

      dev.log('Playing random audio: $filePath');
    } catch (e) {
      dev.log('Error playing random audio: $e');
    }
  }

  Future<void> loopSpecific(BuildContext context, Map<String, String> soundList, String key, {double volume = 1.0}) async {
    try {
      final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
      final isMuted = appStateProvider.getPluginState("MainPluginState")?["sound_muted"] ?? false;

      final filePath = soundList[key];
      if (filePath == null) {
        dev.log('Error: Invalid key "$key" provided.');
        return;
      }

      if (_currentlyPlaying.contains(filePath)) {
        dev.log('Audio "$filePath" is already playing.');
        return;
      }

      for (final path in soundList.values) {
        if (_currentlyPlaying.contains(path)) {
          await stopSound(soundList, soundList.keys.firstWhere((k) => soundList[k] == path));
        }
      }

      if (!_audioPlayers.containsKey(filePath)) {
        _audioPlayers[filePath] = AudioPlayer();
      }

      final player = _audioPlayers[filePath]!;
      await player.setVolume(isMuted ? 0.0 : volume);
      await player.setLoopMode(LoopMode.one);
      await player.setAsset(filePath);
      await player.play();

      _currentlyPlaying.add(filePath);

      dev.log('Looping specific audio: $filePath');
    } catch (e) {
      dev.log('Error looping audio: $e');
    }
  }

  Future<void> loopFromList(BuildContext context, Map<String, String> soundList, {double volume = 1.0}) async {
    try {
      final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
      final isMuted = appStateProvider.getPluginState("MainPluginState")?["sound_muted"] ?? false;

      if (soundList.isEmpty) {
        dev.log('Error: Sound list is empty.');
        return;
      }

      for (final path in soundList.values) {
        if (_currentlyPlaying.contains(path)) {
          await stopSound(soundList, soundList.keys.firstWhere((k) => soundList[k] == path));
        }
      }

      final keys = soundList.keys.toList();
      final randomKey = keys[_random.nextInt(keys.length)];
      final filePath = soundList[randomKey]!;

      if (_currentlyPlaying.contains(filePath)) {
        dev.log('Audio "$filePath" is already playing.');
        return;
      }

      if (!_audioPlayers.containsKey(filePath)) {
        _audioPlayers[filePath] = AudioPlayer();
      }

      final player = _audioPlayers[filePath]!;
      await player.setVolume(isMuted ? 0.0 : volume);
      await player.setLoopMode(LoopMode.one);
      await player.setAsset(filePath);
      await player.play();

      _currentlyPlaying.add(filePath);

      dev.log('Looping random audio: $filePath');
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

      final files = soundList.values.toList();

      for (final filePath in files) {
        if (!_audioPlayers.containsKey(filePath)) {
          _audioPlayers[filePath] = AudioPlayer();
        }

        final player = _audioPlayers[filePath]!;
        await player.setVolume(isMuted ? 0.0 : volume);
        await player.setAsset(filePath);
        await player.play();

        await player.playerStateStream.firstWhere((state) => state.processingState == ProcessingState.completed);
      }
    } catch (e) {
      dev.log('Error playing list in order: $e');
    }
  }

  Future<void> stopSound(Map<String, String> soundList, String key) async {
    try {
      final filePath = soundList[key];
      if (filePath == null) {
        dev.log('Error: Invalid key "$key" provided.');
        return;
      }
      if (_audioPlayers.containsKey(filePath)) {
        await _audioPlayers[filePath]!.stop();
        await _audioPlayers[filePath]!.dispose();
        _audioPlayers.remove(filePath);
      }
      _currentlyPlaying.remove(filePath);
    } catch (e) {
      dev.log('Error stopping sound: $e');
    }
  }

  Future<void> preload(Map<String, String> soundList, String key) async {
    try {
      final filePath = soundList[key];
      if (filePath == null) {
        dev.log('Error: Invalid key "$key" provided.');
        return;
      }
      if (!_preloadedPlayers.containsKey(filePath)) {
        final preloadedPlayer = AudioPlayer();
        await preloadedPlayer.setAsset(filePath);
        _preloadedPlayers[filePath] = preloadedPlayer;
      }
    } catch (e) {
      dev.log('Error preloading audio: $e');
    }
  }

  Future<void> stopAll() async {
    for (var player in _audioPlayers.values) {
      await player.stop();
    }
    _audioPlayers.clear();
    _currentlyPlaying.clear();
  }

  Future<void> stopListSounds(Map<String, String> soundList) async {
    try {
      for (final filePath in soundList.values) {
        if (_audioPlayers.containsKey(filePath)) {
          await _audioPlayers[filePath]!.stop();
          await _audioPlayers[filePath]!.dispose();
          _audioPlayers.remove(filePath);
        }
      }
    } catch (e) {
      dev.log('Error stopping sounds from list: $e');
    }
  }

  Future<void> toggleMute(BuildContext context, bool mute) async {
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);

    for (var player in _audioPlayers.values) {
      await player.setVolume(mute ? 0.0 : 1.0);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMuted', mute);

    appStateProvider.updatePluginState("MainPluginState", {"sound_muted": mute});
    dev.log(mute ? 'All sounds muted and state saved to SharedPreferences.' : 'All sounds unmuted and state saved to SharedPreferences.');
  }

  Future<void> mute(BuildContext context) async {
    try {
      for (var player in _audioPlayers.values) {
        await player.setVolume(0.0);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isMuted', true);

      Provider.of<AppStateProvider>(context, listen: false).updatePluginState("MainPluginState", {"sound_muted": true});

      dev.log('All sounds muted and state saved to SharedPreferences.');
    } catch (e) {
      dev.log('Error muting audio: $e');
    }
  }

  Future<void> unmute(BuildContext context) async {
    try {
      for (var player in _audioPlayers.values) {
        await player.setVolume(1.0);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isMuted', false);

      Provider.of<AppStateProvider>(context, listen: false).updatePluginState("MainPluginState", {"sound_muted": false});

      dev.log('All sounds unmuted and state saved to SharedPreferences.');
    } catch (e) {
      dev.log('Error unmuting audio: $e');
    }
  }

  Future<void> applySavedMuteState(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isMuted = prefs.getBool('isMuted') ?? false;

      for (var player in _audioPlayers.values) {
        await player.setVolume(isMuted ? 0.0 : 1.0);
      }

      Provider.of<AppStateProvider>(context, listen: false).updatePluginState("MainPluginState", {"sound_muted": isMuted});

      dev.log('Applied saved mute state: ${isMuted ? "Muted" : "Unmuted"}');
    } catch (e) {
      dev.log('Error applying saved mute state: $e');
    }
  }
}

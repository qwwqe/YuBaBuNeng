import 'package:audioplayer/audioplayer.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:yu_ba_bu_neng/constants/constants.dart';

class SoundProvider {
  static List<int> numVariants = [1, 2, 3];

  Map<String, List<String>> soundFileNames = {
    SOUND_COMPLETE_ROW: numVariants.map((i) => 'complete_row-0$i.mp3').toList(),
    SOUND_PLACE: numVariants.map((i) => 'place-0$i.mp3').toList(),
    SOUND_PICKUP: numVariants.map((i) => 'pickup-0$i.mp3').toList(),
    SOUND_REPLACE: numVariants.map((i) => 'replace-0$i.mp3').toList(),
    SOUND_SHUFFLE: numVariants.map((i) => 'shuffle-0$i.mp3').toList(),
    SOUND_SORT: numVariants.map((i) => 'sort-0$i.mp3').toList(),
  };
  Map<String, List<String>> soundFileUris = Map<String, List<String>>();

  AudioPlayer audioPlayer;

  bool initialized = false;

  void init() async {
    audioPlayer = AudioPlayer();

    Directory tempDir = await getTemporaryDirectory();
    soundFileNames.forEach((soundType, fileNames) {
      soundFileUris[soundType] = List<String>();
      fileNames.forEach((fileName) async {
        soundFileUris[soundType].add(await _loadSound(fileName, tempDir));
      });
    });

    initialized = true;
  }

  Future<String> _loadSound(String fileName, Directory tempDir) async {
    final ByteData data = await rootBundle.load('assets/audio/$fileName');
    File tempFile = File('${tempDir.path}/$fileName');
    await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
    print('Loaded $fileName');
    return tempFile.uri.toString();
  }

  void play(String soundType) async {
    if(!initialized) {
      print("Skipping premature playback");
      return;
    }

    if(!soundFileUris.containsKey(soundType)) {
      print("Nonexistent sound type: $soundType");
      return;
    }

    int audioIndex = Random().nextInt(soundFileUris[soundType].length);
    String audioUri = soundFileUris[soundType][audioIndex];
    print("Playing $audioUri");

    if(audioPlayer.state == AudioPlayerState.PLAYING) {
      await audioPlayer.stop();
    }

    if(audioPlayer.state == AudioPlayerState.COMPLETED) {
      //audioPlayer.onPlayerStateChanged.
    }

    await audioPlayer.play(audioUri, isLocal: true);
  }

  void stopAll() {
    if(!initialized) {
      return;
    }

    audioPlayer.stop();
  }
}
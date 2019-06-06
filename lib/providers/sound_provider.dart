import 'package:audioplayer/audioplayer.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class SoundProvider {
  static List<int> numVariants = [1, 2, 3];
  static const String COMPLETE_ROW = "completeRow";
  static const String PLACE = "place";
  static const String PICKUP = "pickup";
  static const String REPLACE = "replace";
  static const String SHUFFLE = "shuffle";
  static const String SORT = "sort";

  Map<String, List<String>> soundFileNames = {
    COMPLETE_ROW: numVariants.map((i) => 'complete_row-0$i.mp3'),
    PLACE: numVariants.map((i) => 'place-0$i.mp3'),
    PICKUP: numVariants.map((i) => 'pickup-0$i.mp3'),
    REPLACE: numVariants.map((i) => 'replace-0$i.mp3'),
    SHUFFLE: numVariants.map((i) => 'shuffle-0$i.mp3'),
    SORT: numVariants.map((i) => 'sort-0$i.mp3'),
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

  void _play(String soundType) async {
    if(!initialized) {
      return;
    }
    await audioPlayer.play(soundFileUris[soundType][Random().nextInt(numVariants.length)], isLocal: true);
  }

  void playCompleteRow() {
    _play(COMPLETE_ROW);
  }

  void playPickup() {
    _play(PICKUP);
  }

  void playPlace() {
    _play(PLACE);
  }

  void playReplace() {
    _play(REPLACE);
  }

  void playShuffle() {
    _play(SHUFFLE);
  }

  void playSort() {
    _play(SORT);
  }

  void stopAll() {
    if(!initialized) {
      return;
    }

    audioPlayer.stop();
  }
}
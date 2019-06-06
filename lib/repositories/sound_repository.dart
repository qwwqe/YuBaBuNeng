import 'package:yu_ba_bu_neng/providers/providers.dart';

class SoundRepository {
  SoundProvider soundProvider;

  SoundRepository() {
    soundProvider = SoundProvider();
    soundProvider.init();
  }

  void playCompleteRow() {
    soundProvider.playCompleteRow();
  }

  void playPickup() {
    soundProvider.playPickup();
  }

  void playPlace() {
    soundProvider.playPlace();
  }

  void playReplace() {
    soundProvider.playReplace();
  }

  void playShuffle() {
    soundProvider.playShuffle();
  }

  void playSort() {
    soundProvider.playSort();
  }

  void stopAll() {
    soundProvider.stopAll();
  }
}
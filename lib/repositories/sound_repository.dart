import 'package:yu_ba_bu_neng/providers/providers.dart';

class SoundRepository {
  SoundProvider soundProvider;

  SoundRepository() {
    soundProvider = SoundProvider();
    soundProvider.init();
  }

  void play(String soundType) {
    soundProvider.play(soundType);
  }

  void stopAll() {
    soundProvider.stopAll();
  }
}
import 'dart:core';
import 'package:yu_ba_bu_neng/models/models.dart';
import 'package:yu_ba_bu_neng/providers/providers.dart';

class ChengYuRepository {
  ChengYuProvider chengYuProvider;

  ChengYuRepository() {
    chengYuProvider = ChengYuProvider();
  }
  
  Future<List<ChengYu>> getRandomChengYu(int amount, {String like}) async {
    return chengYuProvider.getRandomChengYu(amount, like: like);
  }

  Future<List<ChengYu>> getUnseenChengYu(int amount, {String like, String unlike}) async {
    return chengYuProvider.getUnseenChengYu(amount, like: like, unlike: unlike);
  }

  Future<List<ChengYu>> getLearningChengYu(int amount, {bool random = false, String like}) async {
    return chengYuProvider.getLearningChengYu(amount, random: random, like: like);
  }

  Future<List<ChengYu>> getLearnedChengYu(int amount, {bool random = false, String like}) async {
    return chengYuProvider.getLearnedChengYu(amount, random: random, like: like);
  }

  void saveChengYu(List<ChengYu> chengYu) async {
    chengYuProvider.saveChengYu(chengYu);
  }

  void saveStats(List<ChengYu> chengYu, {newCardLimit}) async {
    chengYuProvider.saveStats(chengYu, newCardLimit: newCardLimit);
  }
}
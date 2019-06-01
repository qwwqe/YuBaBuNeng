import 'dart:core';
import 'package:yu_ba_bu_neng/models/models.dart';
import 'package:yu_ba_bu_neng/providers/providers.dart';

class ChengYuRepository {
  ChengYuProvider chengYuProvider;

  ChengYuRepository() {
    chengYuProvider = ChengYuProvider();
  }
  
  Future<List<ChengYu>> getRandomChengYu(int amount) async {
    return chengYuProvider.getRandomChengYu(amount);
  }

  Future<List<ChengYu>> getUnseenChengYu(int amount) async {
    return chengYuProvider.getUnseenChengYu(amount);
  }

  Future<List<ChengYu>> getLearningChengYu(int amount, {bool random = false}) async {
    return chengYuProvider.getLearningChengYu(amount, random: random);
  }

  Future<List<ChengYu>> getLearnedChengYu(int amount, {bool random = false}) async {
    return chengYuProvider.getLearnedChengYu(amount, random: random);
  }

  void saveChengYu(List<ChengYu> chengYu) async {
    chengYuProvider.saveChengYu(chengYu);
  }
}
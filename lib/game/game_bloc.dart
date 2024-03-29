import 'package:bloc/bloc.dart';
import 'game.dart';
import 'dart:math';
import 'package:meta/meta.dart';
import 'package:yu_ba_bu_neng/models/models.dart';
import 'package:yu_ba_bu_neng/repositories/repositories.dart';
import 'package:yu_ba_bu_neng/constants/constants.dart';

const int SETUP_RETRY_ATTEMPTS = 5;

class GameBloc extends Bloc<GameEvent, GameState> {
  final ChengYuRepository chengYuRepository;
  final SoundRepository soundRepository;
  final Game game;

  GameBloc({@required this.chengYuRepository, @required this.soundRepository, @required this.game}) :
      assert(chengYuRepository != null),
      assert(soundRepository != null),
      assert(game != null);

  @override
  GameState get initialState => GameLoading();

  @override
  Stream<GameState> mapEventToState(GameEvent event) async* {

    if(event is LoadGame) {
      yield GameLoading();

      for(int i = 0; i <= SETUP_RETRY_ATTEMPTS; i++) {
        int learnedAmt = 6;
        int learningAmt = 4;
        int familiarAmt = learnedAmt + learningAmt;

        List<ChengYu> borderChengYu = await chengYuRepository
            .getLearningChengYu(learningAmt);
        borderChengYu.addAll(await chengYuRepository.getLearnedChengYu(
            familiarAmt - borderChengYu.length));
        print(borderChengYu.map((c) => c.chengYu));
        if (borderChengYu.length != familiarAmt) {
          borderChengYu.addAll(await chengYuRepository.getUnseenChengYu(
              familiarAmt - borderChengYu.length));
        }

        borderChengYu.shuffle();

        ChengYu leftPivotChengYu = borderChengYu.removeLast();
        ChengYu rightPivotChengYu = borderChengYu.removeLast();

        print("left pivot: ${leftPivotChengYu.chengYu}, right pivot: ${rightPivotChengYu.chengYu}");

        List<ChengYu> leftCrossChengYu = List<ChengYu>();
        List<ChengYu> firstLeftCross = await chengYuRepository.getUnseenChengYu(
            1, like: "__${leftPivotChengYu.chengYu[2]}_");

        if (firstLeftCross.length == 0) {
          print("Failed on firstLeftCross (couldn't match \"__${leftPivotChengYu
              .chengYu[2]}_\")");
          continue;
        }
        leftCrossChengYu.add(firstLeftCross[0]);

        List<ChengYu> secondLeftCross = await chengYuRepository
            .getUnseenChengYu(1, like: "${firstLeftCross[0].chengYu[0]}___");

        if (secondLeftCross.length == 0) {
          print("Failed on secondLeftCross (couldn't match \"${firstLeftCross[0]
              .chengYu[0]}___\")");
          continue;
        }
        leftCrossChengYu.add(secondLeftCross[0]);

        // Retrieve two unseen chengyu for right two slots.

        List<ChengYu> rightCrossChengYu = List<ChengYu>();
        List<ChengYu> firstRightCross = await chengYuRepository
            .getUnseenChengYu(1, like: "_${rightPivotChengYu.chengYu[1]}__");
        if (firstRightCross.length == 0) {
          print(
              "Failed on firstRightCross (couldn't match \"_${rightPivotChengYu
                  .chengYu[1]}__\")");
          continue;
        }
        rightCrossChengYu.add(firstRightCross[0]);

        List<ChengYu> secondRightCross = await chengYuRepository
            .getUnseenChengYu(1, like: "___${firstRightCross[0].chengYu[3]}");
        if (secondRightCross.length == 0) {
          print(
              "Failed on secondRightCross (couldn't match \"___${firstRightCross[0]
                  .chengYu[3]}\")");
          continue;
        }
        rightCrossChengYu.add(secondRightCross[0]);

        game.loadChengyu(borderChengYu, leftPivotChengYu, leftCrossChengYu,
            rightPivotChengYu, rightCrossChengYu);
        if (!game.setupGame()) {
          print("Failed on setupGame().");
          yield GameLoadingFailed();
          return;
        }

        yield GameRunning();
        return;
      }
      yield GameLoadingFailed();
    }

    if(event is SelectTileFromRack) {
      game.selectedRackTile = game.selectedRackTile == event.i ? -1 : event.i;
      yield TileSelectedFromRack(i: game.selectedRackTile);
    }

    if(event is ShuffleTileRack) {
      game.selectedRackTile = -1;
      game.shuffleTileRack();
      yield TileRackShuffled();
    }

    if(event is SortTileRack) {
      game.selectedRackTile = -1;
      game.sortTileRack();
      yield TileRackSorted();
    }

    if(event is PlaceTileOnBoard) {
      var tileRack = game.getTileRack();
      var result = game.placeTile(event.x, event.y, tileRack[game.selectedRackTile]);
      if(result.correct) {
        List<Map<String, int>> completedCoords = game.getCompletedFromCoords(event.x, event.y);
      }
      var selectedChengYuList = game.getChengYuAtPosition(event.x, event.y);
      print(selectedChengYuList.map((c) => c.chengYu).toList());
      print("Placement correct? ${result.correct ? "Yes" : "No"}");
      // TODO: update stats
      selectedChengYuList.forEach((c) {
        if(result.placed) {
          c.recordGuess(result.correct);
        }
      });
      yield TilePlacedOnBoard(x: event.x, y: event.y, c: event.c, result: result);

      if (game.isComplete()) {
        int newChengYuLimit = 1;
        var recordedChengyu = List<ChengYu>();
        for(int i = 0; i < game.chengYuList.length; i++) {
          if(game.chengYuList[i].isNew()) {
            if(newChengYuLimit <= 0) {
              continue;
            } else {
              newChengYuLimit--;
            }
          }

          game.chengYuList[i].processSRS();
          recordedChengyu.add(game.chengYuList[i]);
        }

        chengYuRepository.saveStats(recordedChengyu);
        yield GameFinished();
      }
    }

    if(event is RemoveTileFromBoard) {
      var result = game.removeTile(event.x, event.y);
      if (result) {
        yield TileRemovedFromBoard(x: event.x, y: event.y);
      }
    }
  }
}
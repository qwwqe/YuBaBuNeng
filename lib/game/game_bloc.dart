import 'package:bloc/bloc.dart';
import 'game.dart';
import 'dart:math';
import 'package:meta/meta.dart';
import 'package:yu_ba_bu_neng/models/models.dart';
import 'package:yu_ba_bu_neng/repositories/repositories.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final ChengYuRepository chengYuRepository;
  final Game game;

  GameBloc({@required this.chengYuRepository, @required this.game}) :
      assert(chengYuRepository != null),
      assert(game != null);

  @override
  GameState get initialState => GameLoading();

  @override
  Stream<GameState> mapEventToState(GameEvent event) async* {
    if(event is LoadGame) {
      yield GameLoading();

      List<ChengYu> learnedChengYu = await chengYuRepository.getLearnedChengYu(6);
      if(learnedChengYu.length != 6) {
        learnedChengYu.addAll(await chengYuRepository.getUnseenChengYu(6 - learnedChengYu.length));
      }

      List<ChengYu> learningChengYu = await chengYuRepository.getLearningChengYu(4);
      if(learningChengYu.length != 4) {
        learningChengYu.addAll(await chengYuRepository.getUnseenChengYu(4 - learningChengYu.length));
      }

      ChengYu leftPivotChengYu = learnedChengYu.removeLast();
      ChengYu rightPivotChengYu = learnedChengYu.removeLast();

      // Retrieve two unseen chengyu for left two slots.
      
      List<ChengYu> leftCrossChengYu = List<ChengYu>();
      List<ChengYu> firstLeftCross = await chengYuRepository.getUnseenChengYu(1, like: "__${leftPivotChengYu.chengYu[2]}_");
      if (firstLeftCross.length == 0) {
        yield GameLoadingFailed();
        return;
      }
      leftCrossChengYu.add(firstLeftCross[0]);

      List<ChengYu> secondLeftCross = await chengYuRepository.getUnseenChengYu(1, like: "${firstLeftCross[0].chengYu[0]}___");
      if (secondLeftCross.length == 0) {
        yield GameLoadingFailed();
        return;
      }
      leftCrossChengYu.add(secondLeftCross[0]);

      // Retrieve two unseen chengyu for right two slots.
      
      List<ChengYu> rightCrossChengYu = List<ChengYu>();
      List<ChengYu> firstRightCross = await chengYuRepository.getUnseenChengYu(1, like: "_${rightPivotChengYu.chengYu[1]}__");
      if (firstRightCross.length == 0) {
        yield GameLoadingFailed();
        return;
      }
      rightCrossChengYu.add(firstRightCross[0]);
      
      List<ChengYu> secondRightCross = await chengYuRepository.getUnseenChengYu(1, like: "___${firstRightCross[0].chengYu[3]}");
      if (secondRightCross.length == 0) {
        yield GameLoadingFailed();
        return;
      }
      rightCrossChengYu.add(secondRightCross[0]);

      List<ChengYu> borderChengYu = List<ChengYu>();
      borderChengYu.addAll(learnedChengYu);
      borderChengYu.addAll(learningChengYu);
      borderChengYu.sort((cx, cy) => Random().nextBool() ? 1 : -1);

      game.loadChengyu(borderChengYu, leftPivotChengYu, leftCrossChengYu, rightPivotChengYu, rightCrossChengYu);
      if(!game.setupGame()) {
        yield GameLoadingFailed();
        return;
      }

      yield GameRunning();
    }

    if(event is SelectTileFromRack) {
      game.selectedRackTile = event.i;
      yield TileSelectedFromRack();
    }

    if(event is PlaceTileOnBoard) {
      var correct = game.placeTile(event.x, event.y, game.getTileRack()[game.selectedRackTile]);
      var selectedChengYuList = game.getChengYuAtPosition(event.x, event.y);
      // TODO: update stats
//      selectedChengYuList.forEach((c) {
//        if(correct) {
//          c.correctGuess();
//        } else {
//          c.incorrectGuess();
//        }
//      });
      yield TilePlacedOnBoard();
    }

    if(event is RemoveTileFromBoard) {
      game.removeTile(event.x, event.y);
      yield TileRemovedFromBoard();
    }
  }
}
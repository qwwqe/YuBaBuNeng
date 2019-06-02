import 'package:bloc/bloc.dart';
import 'game.dart';
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
      game.setupGame();
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
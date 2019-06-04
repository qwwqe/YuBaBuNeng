import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:yu_ba_bu_neng/models/models.dart';

abstract class GameEvent extends Equatable {
  GameEvent([List props = const []]) : super(props);
}

class LoadGame extends GameEvent {
  final String gameType;

  LoadGame({@required this.gameType}) : assert(gameType != null), super([gameType]);

  @override
  String toString() => "LoadGame";
}

class SelectTileFromRack extends GameEvent {
  final int i;

  SelectTileFromRack({@required this.i}) :
        assert(i != null),
        super([i]);

  @override
  String toString() => "SelectTile";
}

class PlaceTileOnBoard extends GameEvent {
  final int x;
  final int y;

  PlaceTileOnBoard({@required this.x, @required this.y}) :
        assert(x != null),
        assert(y != null),
        super([x, y]);

  @override
  String toString() => "PlaceTileOnBoard";
}

class RemoveTileFromBoard extends GameEvent {
  final int x;
  final int y;

  RemoveTileFromBoard({@required this.x, @required this.y}) :
      assert(x != null),
      assert(y != null),
      super([x, y]);

  @override
  String toString() => "RemoveTileFromBoard";
}

class ShuffleTileRack extends GameEvent {
  @override
  String toString() => "ShuffleTileRack";
}
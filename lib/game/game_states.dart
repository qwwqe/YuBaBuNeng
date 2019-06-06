import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:yu_ba_bu_neng/models/models.dart';

abstract class GameState extends Equatable {
  GameState([List props = const []]) : super(props);
}

class GameLoading extends GameState {
  @override
  String toString() => "GameLoading";
}

class GameLoadingFailed extends GameState {
  @override
  String toString() => "GameLoadingFailed";
}

class GameRunning extends GameState {
  @override
  String toString() => "GameRunning";
}

class TileSelectedFromRack extends GameState {
  final int i;

  TileSelectedFromRack({@required this.i}) : assert(i != null), super([i]);

  @override
  String toString() => "TileSelectedFromRack";
}

class TilePlacedOnBoard extends GameState {
  final int x;
  final int y;
  final String c;
  final PlacementResult result;

  TilePlacedOnBoard({this.x, this.y, this.c, this.result}) : super([x, y, c, result]);

  @override
  String toString() => "TilePlacedOnBoard";
}

class TileRemovedFromBoard extends GameState {
  final int x;
  final int y;

  TileRemovedFromBoard({this. x, this.y}) : super([x, y]);

  @override
  String toString() => "TileRemovedFromBoard";
}

class TileRackShuffled extends GameState {
  TileRackShuffled() : super([DateTime.now()]);

  @override
  String toString() => "TileRackShuffled";
}

class TileRackSorted extends GameState {
  TileRackSorted() : super([DateTime.now()]);

  @override
  String toString() => "TileRackSorted";
}

class RowCompleted extends GameState {
  @override
  String toString() => "RowCompleted";
}

class GameFinished extends GameState {
  @override
  String toString() => "GameFinished";
}
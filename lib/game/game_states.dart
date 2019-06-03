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
  @override
  String toString() => "TilePlacedOnBoard";
}

class TileRemovedFromBoard extends GameState {
  @override
  String toString() => "TileRemovedFromBoard";
}

class GameFinished extends GameState {
  @override
  String toString() => "GameFinished";
}
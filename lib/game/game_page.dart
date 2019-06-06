import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:yu_ba_bu_neng/repositories/repositories.dart';
import 'game.dart';
import 'package:yu_ba_bu_neng/models/models.dart';
import 'package:flutter/services.dart';
import 'package:yu_ba_bu_neng/constants/constants.dart';

class GamePage extends StatefulWidget {
  final ChengYuRepository chengYuRepository;
  final SoundRepository soundRepository;
  final String gameType;

  GamePage({Key key, @required this.chengYuRepository, @required this.soundRepository, @required this.gameType}) :
        assert(chengYuRepository != null),
        assert(gameType != null),
        super(key: key);

  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  Game game;
  GameBloc gameBloc;

  SoundRepository get _soundRepository => widget.soundRepository;

  @override
  void initState() {
    game = Game();
    gameBloc = GameBloc(chengYuRepository: widget.chengYuRepository, soundRepository: _soundRepository, game: game);
    gameBloc.dispatch(LoadGame(gameType: CustomGameType));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return BlocProvider(
      bloc: gameBloc,
      child: Scaffold(
        //appBar: AppBar(
        //  title: Text(widget.gameType),
        //),
        body: BlocListener(
          bloc: gameBloc,
          listener: (context, state) {
            if(state is GameLoadingFailed) {
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text("Failed loading game")));
            }

            if(state is TileSelectedFromRack) {
              _soundRepository.play(SOUND_PICKUP);
            }

            if(state is TilePlacedOnBoard) {
              if(state.result.solved && state.result.correct) {
                _soundRepository.play(SOUND_COMPLETE_ROW);
              } else {
                _soundRepository.play(SOUND_PLACE);
              }
            }

            if(state is TileRemovedFromBoard) {
              _soundRepository.play(SOUND_REPLACE);
            }

            if(state is TileRackShuffled) {
              _soundRepository.play(SOUND_SHUFFLE);
            }

            if(state is TileRackSorted) {
              _soundRepository.play(SOUND_SORT);
            }
          },
          child: BlocBuilder(
              bloc: gameBloc,
              builder: (context, state) {
                if(state is GameLoading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if(state is GameLoadingFailed) {
                  return Center(
                    child: Icon(Icons.error),
                  );
                }

                if(state is GameFinished) {
                  return Center(child: Text("DONE"));
                }

                print(game.selectedRackTile);

                return Container(
                  child: Column(
                    children: [
//                      Container(
//                        child: Column(
//                          children: boardRows,
//                        ),
//                      ),
                      Board(game: game, gameBloc: gameBloc, soundRepository: _soundRepository),
                      Spacer(),
                      TileRack(game: game),
                      Spacer(),
                      Row(
                        children: <Widget>[
                          Spacer(),
                          IconButton(
                            color: Colors.white70,
                            padding: EdgeInsets.all(0),
                            iconSize: 30,
                            onPressed: () {
                              //_soundRepository.play(SOUND_SORT);
                              gameBloc.dispatch(SortTileRack());
                            },
                            icon: Icon(Icons.autorenew),
                          ),
                          IconButton(
                            color: Colors.white70,
                            padding: EdgeInsets.all(0),
                            iconSize: 30,
                            onPressed: () {
                              //_soundRepository.play(SOUND_SHUFFLE);
                              gameBloc.dispatch(ShuffleTileRack());
                            },
                            icon: Icon(Icons.shuffle),
                          ),
                          Spacer(),
                        ],
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(5),
                  color: Colors.brown,
                );
              }
          ),
        ),
      ),
    );
  }
}
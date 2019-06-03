import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:yu_ba_bu_neng/repositories/repositories.dart';
import 'game.dart';
import 'package:yu_ba_bu_neng/models/models.dart';

class GamePage extends StatefulWidget {
  final ChengYuRepository chengYuRepository;
  final String gameType;

  GamePage({Key key, @required this.chengYuRepository, @required this.gameType}) :
        assert(chengYuRepository != null),
        assert(gameType != null),
        super(key: key);

  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  Game game;
  GameBloc gameBloc;

  @override
  void initState() {
    game = Game();
    gameBloc = GameBloc(chengYuRepository: widget.chengYuRepository, game: game);
    gameBloc.dispatch(LoadGame(gameType: CustomGameType));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameType),
      ),
      body: BlocListener(
          bloc: gameBloc,
          listener: (context, state) {
            if (state is GameLoadingFailed) {
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text("Failed loading game")));
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
                  return Text("DONE");
                }

                // TODO: grid
                var rows = List<Row>();
                var tileGrid = game.getTileGrid();
                tileGrid.forEach((tileRow) {
                  rows.add(Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: tileRow.map((tile) {
                      return Container(
                          child: Center(
                            child: Text(tile.value == "" ? " " : tile.value,
                              style: TextStyle(
                                fontSize: 20,
                                color: tile.fixed ? Colors.red : Colors.black54,
                              ),
                            ),
                          ),
                          color: tile.playable ? Colors.lightBlueAccent : Colors.white70,
                      );
                    }).toList(),
                  ));
                });

                return Column(
                  children: rows,
                );
              }
          ),
      ),
    );
  }
}
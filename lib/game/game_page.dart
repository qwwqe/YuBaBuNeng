import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:yu_ba_bu_neng/repositories/repositories.dart';
import 'game.dart';
import 'package:yu_ba_bu_neng/models/models.dart';
import 'package:flutter/services.dart';

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
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      //appBar: AppBar(
      //  title: Text(widget.gameType),
      //),
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
                  return Center(child: Text("DONE"));
                }
//
//                var boardRows = List<Row>();
//                var tileGrid = game.getTileGrid();
//                for(int y = 0; y < tileGrid.length; y++) {
//                  List<Expanded> gridTiles = List<Expanded>();
//                  for(int x = 0; x < tileGrid[0].length; x++) {
//                    var tileText;
//                    var tileTextColor;
//                    var tileColor;
//
//                    var tile = tileGrid[y][x];
//
//                    if(tile.solved) {
//                      tileText = tile.value;
//                      tileTextColor = Colors.white;
//                      tileColor = Colors.brown[300];
//                    } else if(tile.fixed) {
//                      tileText = tile.value;
//                      tileTextColor = Colors.cyan[100];
//                      tileColor = tile.playable ? Colors.black : Colors.white70;
//                    } else if(tile.value != "") {
//                      tileText = tile.value;
//                      tileTextColor = Colors.white;
//                      tileColor = tile.playable ? Colors.black : Colors.white70;
//                    } else {
//                      tileText = "空";
//                      tileTextColor = Colors.transparent;
//                      tileColor = tile.playable ? Colors.black : Colors.white70;
//                    }
//
//                    var e = Expanded(
//                        child: GestureDetector(
//                          onTap: () {
//                            if(tile.solved) {
//                              return;
//                            }
//
//                            if(game.selectedRackTile >= 0) {
//                              HapticFeedback.lightImpact();
//                              SystemSound.play(SystemSoundType.click);
//                              gameBloc.dispatch(PlaceTileOnBoard(x: x, y: y));
//                            } else {
//                              HapticFeedback.lightImpact();
//                              SystemSound.play(SystemSoundType.click);
//                              gameBloc.dispatch(RemoveTileFromBoard(x: x, y: y));
//                            }
//                          },
//                          onLongPress: () {
//                            var chengYuList = game.getChengYuAtPosition(x, y);
//                            if (chengYuList.length > 0) {
//                              var chengYu = chengYuList[0];
//                              print(chengYu.chengYu);
//
//                              var modalContent = List<Widget>();
//                              modalContent.add(Text(tile.solved ? chengYu.chengYu : "定義",
//                                style: TextStyle(
//                                  fontSize: 20,
//                                ),
//                                textAlign: TextAlign.center,
//                              ));
//
//                              if (tile.solved) {
//                                modalContent.add(Text(chengYu.zhuYin.replaceAll(RegExp(r'\s+'), ""),
//                                  style: TextStyle(
//                                    fontSize: 20,
//                                  ),
//                                  textAlign: TextAlign.center,
//                                ));
//                              }
//
//                              var definition = chengYu.shiYi;
//                              if (!tile.solved) {
//                                definition = definition.replaceAll(chengYu.chengYu, "****");
//                                definition = definition.replaceAll(chengYu.chengYu.substring(0, 2), "**");
//                                definition = definition.replaceAll(chengYu.chengYu.substring(2, 4), "**");
//                              }
//                              modalContent.add(Text(definition,
//                                style: TextStyle(
//                                  fontSize: 20,
//                                ),
//                              ));
//
//                              showModalBottomSheet(
//                                  context: context,
//                                  builder: (context) => Container(
//                                      padding: EdgeInsets.all(4),
//                                      child: Column(
//                                        children: modalContent,
//                                      )
//                                  ),
//                              );
//                            }
//                          },
//                          child: Container(
//                            margin: EdgeInsets.all(1),
//                            child: Center(
//                              child: Text(tileText,
//                                style: TextStyle(
//                                  fontSize: 22,
//                                  color: tileTextColor,
//                                ),
//                              ),
//                            ),
//                            color: tileColor,
//                          ),
//                        ),
//                    );
//
//                    gridTiles.add(e);
//                  }
//
//                  boardRows.add(Row(
//                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                    textBaseline: TextBaseline.ideographic,
//                    children: gridTiles,
//                  ));
//                }

                print(game.selectedRackTile);

                return Container(
                  child: Column(
                    children: [
//                      Container(
//                        child: Column(
//                          children: boardRows,
//                        ),
//                      ),
                      Board(game: game, gameBloc: gameBloc),
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
                            onPressed: () => gameBloc.dispatch(SortTileRack()),
                            icon: Icon(Icons.autorenew),
                          ),
                          IconButton(
                            color: Colors.white70,
                            padding: EdgeInsets.all(0),
                            iconSize: 30,
                            onPressed: () => gameBloc.dispatch(ShuffleTileRack()),
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
    );
  }
}
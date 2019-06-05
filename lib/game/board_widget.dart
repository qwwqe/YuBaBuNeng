import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yu_ba_bu_neng/models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:path_provider/path_provider.dart';
import 'game.dart';

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

class Board extends StatefulWidget {
  final GameBloc gameBloc;
  final Game game;

  Board({@required this.gameBloc, @required this.game}) : assert(gameBloc != null), assert(game != null);

  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> {
  GameBloc get _gameBloc => widget.gameBloc;
  Game get _game => widget.game;

  AudioPlayer audioPlayer;
  AudioPlayerState audioPlayerState;
  String mp3Uri;

  @override
  void initState() {
    audioPlayer = AudioPlayer();
    _load();
    super.initState();
  }

  // TODO: move this to main page
  Future<Null> _load() async {
    final ByteData data = await rootBundle.load('assets/audio/replace-01.mp3');
    Directory tempDir = await getTemporaryDirectory();
    File tempFile = File('${tempDir.path}/replace-01.mp3');
    await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
    mp3Uri = tempFile.uri.toString();
    print('finished loading, uri=$mp3Uri');
  }

  @override
  Widget build(BuildContext context) {
    var boardRows = List<Row>();
    var tileGrid = _game.getTileGrid();
    for(int y = 0; y < tileGrid.length; y++) {
      List<Expanded> gridTiles = List<Expanded>();
      for(int x = 0; x < tileGrid[0].length; x++) {
        var tileText;
        var tileTextColor;
        var tileColor;

        var tile = tileGrid[y][x];

        if(tile.solved) {
          tileText = tile.value;
          tileTextColor = Colors.white;
          tileColor = Colors.brown[300];
        } else if(tile.fixed) {
          tileText = tile.value;
          tileTextColor = Colors.cyan[100];
          tileColor = tile.playable ? Colors.black : Colors.white70;
        } else if(tile.value != "") {
          tileText = tile.value;
          tileTextColor = Colors.white;
          tileColor = tile.playable ? Colors.black : Colors.white70;
        } else {
          tileText = "空";
          tileTextColor = Colors.transparent;
          tileColor = tile.playable ? Colors.black : Colors.white70;
        }

        var e = Expanded(
          child: GestureDetector(
            onTap: () async {
              if(tile.solved) {
                return;
              }

              if(_game.selectedRackTile >= 0) {
                HapticFeedback.lightImpact();
                SystemSound.play(SystemSoundType.click);
                _gameBloc.dispatch(PlaceTileOnBoard(x: x, y: y, c: tile.value));
              } else {
                HapticFeedback.lightImpact();
                //SystemSound.play(SystemSoundType.click);
                await audioPlayer.play(mp3Uri, isLocal: true);
                _gameBloc.dispatch(RemoveTileFromBoard(x: x, y: y));
              }
            },
            onLongPress: () {
              var chengYuList = _game.getChengYuAtPosition(x, y);
              if (chengYuList.length > 0) {
                var chengYu = chengYuList[0];
                print(chengYu.chengYu);

                var modalContent = List<Widget>();
                modalContent.add(Text(tile.solved ? chengYu.chengYu : "定義",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ));

                if (tile.solved) {
                  modalContent.add(Text(chengYu.zhuYin.replaceAll(RegExp(r'\s+'), ""),
                    style: TextStyle(
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ));
                }

                var definition = chengYu.shiYi;
                if (!tile.solved) {
                  definition = definition.replaceAll(chengYu.chengYu, "****");
                  definition = definition.replaceAll(chengYu.chengYu.substring(0, 2), "**");
                  definition = definition.replaceAll(chengYu.chengYu.substring(2, 4), "**");
                }
                modalContent.add(Text(definition,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ));

                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                      padding: EdgeInsets.all(4),
                      child: Column(
                        children: modalContent,
                      )
                  ),
                );
              }
            },
            child: Container(
              margin: EdgeInsets.all(1),
              child: Center(
                child: Text(tileText,
                  style: TextStyle(
                    fontSize: 22,
                    color: tileTextColor,
                  ),
                ),
              ),
              color: tileColor,
            ),
          ),
        );

        gridTiles.add(e);
      }

      boardRows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        textBaseline: TextBaseline.ideographic,
        children: gridTiles,
      ));
    }

    return Container(
      child: Column(
        children: boardRows,
      ),
    );
  }
}


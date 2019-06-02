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
      body: BlocBuilder(
        bloc: gameBloc,
        builder: (context, state) {
          if(state is GameLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if(state is GameFinished) {
            return Text("DONE");
          }

          // TODO: grid
        }
      ),
//      Center(
//          child: Text(widget.gameType)
//      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:yu_ba_bu_neng/game/game.dart';
import 'package:yu_ba_bu_neng/repositories/repositories.dart';
import 'package:yu_ba_bu_neng/constants/constants.dart';

class PrintTransitionDelegate extends BlocDelegate {
  @override
  void onTransition(Transition transition) {
    debugPrint(transition.toString());
  }
}

void main() async {
  BlocSupervisor().delegate = PrintTransitionDelegate();
  var chengYuRepository = ChengYuRepository();

  // TODO: consider wrapping this repo in a Sound object instead, since it's not accessed through a bloc anyway
  var soundRepository = SoundRepository();
  runApp(MainApp(chengYuRepository: chengYuRepository, soundRepository: soundRepository));
}

class MainApp extends StatefulWidget {
  final ChengYuRepository chengYuRepository;
  final SoundRepository soundRepository;

  MainApp({Key key, @required this.chengYuRepository, @required this.soundRepository}) :
      assert(chengYuRepository != null),
      assert(soundRepository != null),
      super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ChengYuRepository get _chengYuRepository => widget.chengYuRepository;
  SoundRepository get _soundRepository => widget.soundRepository;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: "欲罷不能",
    home: Scaffold(
      appBar: AppBar(
        title: Text("欲罷不能"),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 160, horizontal: 20),
        child: Center(
          child: Column(
            children: [
              Builder(
                builder: (context) => RaisedButton(
                  child: Text("個人遊戲"),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GamePage(
                        gameType: CustomGameType,
                        chengYuRepository: _chengYuRepository,
                        soundRepository: _soundRepository,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.all(10)),
              Builder(
                builder: (context) => RaisedButton(
                  child: Text("隨機遊戲"),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GamePage(
                          gameType: RandomGameType,
                          chengYuRepository: _chengYuRepository,
                          soundRepository: _soundRepository,
                        ),
                      )
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.all(10)),
              RaisedButton(
                child: Text("學習進度"),
                onPressed: null,
              ),
            ],
          )
        ),
      )
    ),
  );
}
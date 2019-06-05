import 'package:flutter/material.dart';
import 'package:yu_ba_bu_neng/models/models.dart';
import 'package:flutter/services.dart';

class TileRack extends StatefulWidget {
  final Game game;

  TileRack({Key key, @required this.game}) : assert(game != null), super(key: key);

  @override
  _TileRackState createState() => _TileRackState();
}

class _TileRackState extends State<TileRack> {
  Game get _game => widget.game;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> tileStrings = _game.getTileRack();
    List<GestureDetector> tiles = List<GestureDetector>();
    for(int i = 0; i < tileStrings.length; i++) {
      var textColor;
      var bgColor;
      var borderColor;
      if (tileStrings[i] == "") {
        textColor = bgColor = borderColor = Colors.transparent;
      } else if (i == _game.selectedRackTile) {
        textColor = Colors.brown;
        bgColor = Colors.black;
        borderColor = Colors.black;
      } else {
        textColor = Colors.white;
        borderColor = Colors.black;
        bgColor = Colors.transparent;
      }

      tiles.add(GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            SystemSound.play(SystemSoundType.click);
            //gameBloc.dispatch(SelectTileFromRack(i: i));
            setState(() {
              _game.selectedRackTile = i;
            });
          },
          child: Container(
            padding: EdgeInsets.all(1),
            child: Text(tileStrings[i],
                style: TextStyle(
                  fontSize: 24,
                  color: textColor,
                )
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: borderColor,
                width: 1.5,
              ),
              color: bgColor,
            ),
          )
      ));
    }

    return Wrap(
      children: tiles,
      spacing: 2,
      runSpacing: 2,
    );
  }
}
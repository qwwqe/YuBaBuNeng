import 'models.dart';
import 'dart:math';

const int Vertical = 1;
const int Horizontal = 2;

class Game {
  int size = 11;
  List<ChengYu> chengYuList;
  List<Slot> slots;
  List<String> _usableChars;

  List<ChengYu> borderChengYu;
  ChengYu leftPivotChengYu;
  ChengYu rightPivotChengYu;
  List<ChengYu> leftCrossChengYu;
  List<ChengYu> rightCrossChengYu;

  List<List<Map<Slot, int>>> grid;

  int selectedRackTile = -1;

  //Game(
  //Game(this.chengYuList) : assert(chengYuList.length == 13);
  //Game(int size, {this.chengYuList});

  void loadChengyu(List<ChengYu> borderChengYu, ChengYu leftPivotChengYu, List<ChengYu> leftCrossChengYu, ChengYu rightPivotChengYu, List<ChengYu>rightCrossChengYu) {
    this.borderChengYu = borderChengYu;
    this.leftPivotChengYu = leftPivotChengYu;
    this.leftCrossChengYu = leftCrossChengYu;
    this.rightPivotChengYu = rightPivotChengYu;
    this.rightCrossChengYu = rightCrossChengYu;
  }

  bool setupGame({hard: false}) {
    // compile full chengyu list
    chengYuList = List<ChengYu>();
    chengYuList.addAll(borderChengYu);
    chengYuList.add(leftPivotChengYu);
    chengYuList.addAll(leftCrossChengYu);
    chengYuList.add(rightPivotChengYu);
    chengYuList.addAll(rightCrossChengYu);

    if(chengYuList.length != 14) {
      print("Expected 14 chengyu, got ${chengYuList.length}");
      return false;
    }

    // compile full character list
    _usableChars = List<String>();
    chengYuList.forEach((chengYu) {
      for(int i = 0; i < chengYu.chengYu.length; i++) {
        _usableChars.add(chengYu.chengYu[i]);
      }
    });
    
    // remove overlaps
    _removeUsableChar(leftPivotChengYu.chengYu[2]);
    _removeUsableChar(leftCrossChengYu[0].chengYu[0]);
    _removeUsableChar(rightPivotChengYu.chengYu[1]);
    _removeUsableChar(rightCrossChengYu[0].chengYu[3]);
    print("Usable chars: ${_usableChars.length}");
    print(_usableChars);
    print(leftCrossChengYu[0].chengYu);
    print(rightCrossChengYu[0].chengYu);

    _usableChars.shuffle();

    // generate slots
    slots = List<Slot>();
    grid = List.generate(size, (_) => List(size));
    for(int i = 0; i < chengYuList.length; i++) {
      slots.add(Slot(chengYuList[i]));
    }

    print("before place slot");
    print(slots.length);
    // populate border
    _placeSlot(slots[0], 0, 1, Vertical);
    _placeSlot(slots[1], 0, 6, Vertical);
    _placeSlot(slots[2], 10, 1, Vertical);
    _placeSlot(slots[3], 10, 6, Vertical);

    _placeSlot(slots[4], 1, 0, Horizontal);
    _placeSlot(slots[5], 6, 0, Horizontal);
    _placeSlot(slots[6], 1, 10, Horizontal);
    _placeSlot(slots[7], 6, 10, Horizontal);

    // populate left pivot
    _placeSlot(slots[8], 1, 5, Horizontal);
    _placeSlot(slots[9], 3, 3, Vertical);
    _placeSlot(slots[10], 3, 3, Horizontal);

    print("after place slot");
    // populate right pivot
    _placeSlot(slots[11], 6, 5, Horizontal);
    _placeSlot(slots[12], 7, 4, Vertical);
    _placeSlot(slots[13], 4, 7, Horizontal);

    // generate fixed tiles (border only)
    for(int i = 0; i < 8; i++) {
      _removeUsableChar(slots[i].populateTile());
    }

    if(!hard) {
      for(int i = 8; i < slots.length; i++) {
        int j = Random().nextInt(4);
        if (slots[i].tiles[j].value == "") {
          String c = slots[i].chengYu.chengYu[j];
          int x = slots[i].coords[j]['x'];
          int y = slots[i].coords[j]['y'];
          print("j: $j, c: $c");
          if(grid[y][x] != null) {
            grid[y][x].forEach((slot, offset) {
              slot.setTile(offset, c);
              slot.tiles[offset].fixed = true;
            });

            _removeUsableChar(c);
          }
        }
      }
    }

    return true;
  }

  void _placeSlot(Slot slot, int x, int y, int orientation) {
    for(int i = 0; i < 4 && y < grid.length && x < grid[y].length; i++) { // TODO: maybe abstract to chengyu length
      if(grid[y][x] == null) {
        grid[y][x] = Map<Slot, int>();
      }

      grid[y][x][slot] = i;
      slot.coords.add({'x' : x, 'y': y});

      if (orientation == Vertical) {
        y++;
      } else {
        x++;
      }
    }
  }

  void _removeUsableChar(String c) {
    _usableChars.remove(c);
  }

  void _replaceUsableChar(String c) {
    _usableChars.add(c);
  }

  /// Attempts to place a tile at (x, y).
  PlacementResult placeTile(int x, int y, String value) {
    bool unshelveTile = false;
    bool correct = false;
    Slot solvedSlot;

    if (grid[y][x] != null) {
      var oldValue = "";
      bool anyFixed = false;

      grid[y][x].forEach((slot, offset) {
        anyFixed = anyFixed || slot.canPlaceTile(offset);
        if(slot.canPlaceTile(offset)) {
          print("Can place");
          oldValue = slot.getValueAt(offset);
          unshelveTile = true;
          correct = slot.setTile(offset, value);
          if (slot.tiles[offset].solved) {
            solvedSlot = solvedSlot ?? slot;
          }
        }

        for(int i = 0; i < slot.tiles.length; i++) {
          print("${slot.tiles[i].value}, ${slot.chengYu.chengYu[i]}");
        }
      });

      if(solvedSlot != null) {
        print("BIG DIPPER!!");

        solvedSlot.coords.forEach((coords) {
          int x = coords['x'];
          int y = coords['y'];
          grid[y][x].forEach((slot, offset) {
            print("${slot.chengYu.chengYu} (offset: $offset)");
            slot.tiles[offset].solved = true;
          });
        });
      }

      if (oldValue != "") {
        _replaceUsableChar(oldValue);
      }

      if (unshelveTile) {
        selectedRackTile = -1;
        _removeUsableChar(value);
      }
    }

    var completeCount = 0;
    for (var slot in slots) {
      if(slot.isComplete()) {
        completeCount++;
      }
    }
    print("Complete: $completeCount");

    return PlacementResult(correct: correct, solved: solvedSlot != null, placed: unshelveTile);
  }

  List<Map<String, int>> getCompletedFromCoords(int x, int y) {
    if(grid[y][x] == null) {
      return null;
    }

    var coordList = List<Map<String, int>>();
    grid[y][x].forEach((slot, offset) {
      if (slot.isComplete()) {
        coordList.addAll(slot.coords);
      }
    });

    return coordList;
  }

  bool removeTile(int x, int y) {
    var removed = false;

    if (grid[y][x] != null) {
      String c = "";
      bool anyFixed = false;

      grid[y][x].forEach((slot, offset) {
        if(slot.canDeleteTile(offset)) {
          c = slot.getValueAt(offset);
          slot.unSetTile(offset);
        } else {
          anyFixed = true;
        }
      });

      if(!anyFixed && c != "") {
        removed = true;
        _replaceUsableChar(c);
      }
    }

    return removed;
  }

  List<List<Tile>> getTileGrid() {
    var tileGrid = List.generate(size, (_) => List<Tile>(size));
    for(int i = 0; i < tileGrid.length; i++) {
      for(int j = 0; j < tileGrid[0].length; j++) {
        Tile displayTile;
        if(grid[i][j] != null) {
          var slot = grid[i][j].keys.toList()[0];
          var offset = grid[i][j][slot];
          //print("x: $j, y: $i, offset: $offset, chengyu: ${slot.chengYu.chengYu}");
          var tile = slot.getTileAt(offset);
          displayTile = Tile(value: tile.value, fixed: tile.fixed, solved: tile.solved);
        } else {
          displayTile = Tile(playable: false);
        }
        tileGrid[i][j] = displayTile;
      }
    }

    return tileGrid;
  }

  List<String> getTileRack() {
    return _usableChars;
  }

  void shuffleTileRack() {
    _usableChars.shuffle();
  }

  void sortTileRack() {
    _usableChars.sort();
  }

  bool isComplete() {
    for(int i = 0; i < slots.length; i++) {
      if(!slots[i].isComplete()) {
        return false;
      }
    }
    return true;
  }

  List<ChengYu> getChengYuAtPosition(int x, int y) {
    var cs = List<ChengYu>();
    grid[y][x].forEach((slot, _) {
      cs.add(slot.chengYu);
    });

    return cs;
  }

}

class Slot {
  ChengYu chengYu;
  List<Tile> tiles;
  List<Map<String, int>> coords;

  Slot(ChengYu chengYu) {
    this.chengYu = chengYu;
    tiles = List.generate(4, (i) => Tile());
    coords = List<Map<String, int>>();
  }

  String populateTile() {
    var i = Random().nextInt(chengYu.chengYu.length);
    if(tiles[i].value == "") {
      tiles[i].value = chengYu.chengYu[i];
      tiles[i].fixed = true;

      return chengYu.chengYu[i];
    } else {
      return "";
    }
  }

  void _updateTileCompletionStatus() {
    bool complete = isComplete();
    for (int i = 0; i < tiles.length; i++) {
      tiles[i].solved = tiles[i].solved || complete;
    }
  }

  bool setTile(int offset, String value) {
    if(!tiles[offset].fixed) {
      tiles[offset].value = value;
    }

    _updateTileCompletionStatus();

    return value == chengYu.chengYu[offset];
  }

  void unSetTile(int offset) {
    if(!tiles[offset].fixed) {
      tiles[offset].value = "";
    }
    _updateTileCompletionStatus();
  }

  bool canPlaceTile(int offset) {
    return !tiles[offset].fixed;
  }

  bool canDeleteTile(int offset) {
    return !tiles[offset].fixed;
  }

  String getValueAt(int offset) {
    return tiles[offset].value;
  }

  Tile getTileAt(int offset) {
    //print("--> chengyu: ${chengYu.chengYu}, tiles: $tiles");
    return tiles[offset];
  }

  bool isComplete() {
    for(int i = 0; i < tiles.length && i < chengYu.chengYu.length; i++) {
      if(tiles[i].value != chengYu.chengYu[i]) {
        return false;
      }
    }
    return true;
  }
}

class Tile {
  String value;
  bool fixed;
  bool playable;
  bool solved;

  Tile({this.value = "", this.fixed = false, this.playable = true, this.solved = false});
}

class PlacementResult {
  bool correct;
  bool solved;
  bool placed;

  PlacementResult({this.correct, this.solved, this.placed});
}
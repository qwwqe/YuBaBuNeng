import 'models.dart';
import 'dart:math';

const int Vertical = 1;
const int Horizontal = 2;

class Game {
  int size = 12;
  List<ChengYu> chengYuList;
  List<Slot> slots;
  List<String> usableChars;

  List<ChengYu> borderChengYu;
  ChengYu leftPivotChengYu;
  ChengYu rightPivotChengYu;
  List<ChengYu> leftCrossChengYu;
  List<ChengYu> rightCrossChengYu;

  List<List<Map<Slot, int>>> grid;

  int selectedRackTile;

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

  void setupGame() {
    // compile full chengyu list
    chengYuList = List<ChengYu>();
    chengYuList.addAll(borderChengYu);
    chengYuList.add(leftPivotChengYu);
    chengYuList.addAll(leftCrossChengYu);
    chengYuList.add(rightPivotChengYu);
    chengYuList.addAll(rightCrossChengYu);

    // compile full character list
    usableChars = List<String>();
    chengYuList.forEach((chengYu) {
      for(int i = 0; i < chengYu.chengYu.length; i++) {
        usableChars.add(chengYu.chengYu[i]);
      }
    });
    
    // remove overlaps
    _removeUsableChar(leftPivotChengYu.chengYu[2]);
    _removeUsableChar(leftCrossChengYu[0].chengYu[1]);
    _removeUsableChar(rightPivotChengYu.chengYu[1]);
    _removeUsableChar(rightCrossChengYu[0].chengYu[1]);

    // generate slots
    slots = List<Slot>();
    grid = List.generate(size, (_) => List(size));
    for(int i = 0; i < chengYuList.length; i++) {
      slots.add(Slot(chengYuList[i]));
    }

    // populate border
    _placeSlot(slots[0], 0, 1, Vertical);
    _placeSlot(slots[1], 0, 6, Vertical);
    _placeSlot(slots[2], 11, 1, Vertical);
    _placeSlot(slots[3], 11, 6, Vertical);

    _placeSlot(slots[4], 1, 0, Horizontal);
    _placeSlot(slots[5], 6, 0, Horizontal);
    _placeSlot(slots[6], 1, 11, Horizontal);
    _placeSlot(slots[7], 6, 11, Horizontal);

    // populate left pivot
    _placeSlot(slots[8], 0, 7, Horizontal);
    _placeSlot(slots[9], 3, 3, Vertical);
    _placeSlot(slots[10], 3, 3, Horizontal);

    // populate right pivot
    _placeSlot(slots[11], 6, 5, Horizontal);
    _placeSlot(slots[12], 7, 4, Vertical);
    _placeSlot(slots[13], 4, 7, Horizontal);

    // generate fixed tiles (border only)
    for(int i = 0; i < 8; i++) {
      _removeUsableChar(slots[i].populateTile());
    }

  }

  void _placeSlot(Slot slot, int x, int y, int orientation) {
    for(int i = 0; i < 4 && y < grid.length && x < grid[y].length; i--) { // TODO: maybe abstract to chengyu length
      if(grid[y][x] == null) {
        grid[y][x] = Map<Slot, int>();
      }

      grid[y][x][slot] = i;

      if (orientation == Vertical) {
        y++;
      } else {
        x++;
      }
    }
  }

  void _removeUsableChar(String c) {
    usableChars.remove(c);
  }

  void _replaceUsableChar(String c) {
    usableChars.add(c);
  }

  /// Attempts to place a tile at (x, y).
  /// Returns true if the tile matches the corresponding offset in the chengyu,
  /// false if it does not match, or if no chengyu/slot exists here.
  bool placeTile(int x, int y, String value) {
    bool correct = false;

    if (grid[y][x] != null) {
      grid[y][x].forEach((slot, offset) {
        correct = slot.setTile(offset, value);
      });

      _removeUsableChar(value);
    }

    return correct;
  }

  void removeTile(int x, int y) {
    if (grid[y][x] != null) {
      String c = "";

      grid[y][x].forEach((slot, offset) {
        c = slot.getValueAt(offset);
        slot.unSetTile(offset);
      });

      _replaceUsableChar(c);
    }
  }

  List<List<Tile>> getTileGrid() {
    var tileGrid = List.generate(size, (_) => List(size));
    for(int i = 0; i < tileGrid.length; i++) {
      for(int j = 0; j < tileGrid[0].length; j++) {
        var displayTile;
        if(grid[i][j] != null) {
          var slot = grid[i][j].keys.toList()[0];
          var offset = grid[i][j][slot];
          var tile = slot.getTileAt(offset);
          displayTile = Tile(value: tile.value, fixed: tile.fixed);
        } else {
          displayTile = Tile();
        }
        tileGrid[i][j] = displayTile;
      }
    }

    return tileGrid;
  }

  List<String> getTileRack() {
    return usableChars;
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

  Slot(ChengYu chengYu) {
    this.chengYu = chengYu;
    tiles = List<Tile>();
  }

  String populateTile() {
    tiles = List<Tile>();
    for(int i = 0; i < chengYu.chengYu.length; i++) {
      tiles.add(Tile());
    }
    var i = Random().nextInt(chengYu.chengYu.length);
    tiles[i].value = chengYu.chengYu[i];
    tiles[i].fixed = true;

    return chengYu.chengYu[i];
  }

  bool setTile(int offset, String value) {
    if(!tiles[offset].fixed) {
      tiles[offset].value = value;
    }

    return value == chengYu.chengYu[offset];
  }

  void unSetTile(int offset) {
    if(!tiles[offset].fixed) {
      tiles[offset].value = "";
    }
  }

  String getValueAt(int offset) {
    return tiles[offset].value;
  }

  Tile getTileAt(int offset) {
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

  Tile({this.value, this.fixed});
}
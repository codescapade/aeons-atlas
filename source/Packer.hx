package;

class Packer {
  var rects: Array<Rect>;

  var bounds: Rect;

  var placedRects: Array<Rect> = [];

  var rows: Array<Int> = [];
  var columns: Array<Int> = [];

  var grid: Array<Array<Bool>> = [];

  var placed = 0;

  public var smallestBounds: Rect;

  public var smallestLayout: Array<Rect> = [];

  var biggestWidth = 0;

  var done = false;

  public function new(rects: Array<Rect>) {
    this.rects = rects;
    reset();
    while (!done) {
      nextStep();
    }
  }

  function reset() {
    placed = 0;
    smallestBounds = null;
    smallestLayout = [];
    sortByHeight();

    var boundsWidth = 0;
    var boundsHeight = rects[0].height;
    for (rect in rects) {
      boundsWidth += rect.width;
      if (biggestWidth == 0 || rect.width > biggestWidth) {
        biggestWidth = rect.width;
      }
    }
    bounds = new Rect(0, 0, boundsWidth, boundsHeight);

    rows = [boundsHeight];
    columns = [boundsWidth];
    grid = [[false]];
    done = false;
  }

  function nextStep() {
    if (done) {
      return;
    }
    if (placed < rects.length) {
      var rect = rects[placed];
      if (placeRect(rect)) {
        placedRects.push(rect);
        placed++;
      } else {
        bounds.height += rect.height;
        placedRects = [];
        placed = 0;
        grid = [[false]];
        columns = [bounds.width];
        rows = [bounds.height];
        trace('new width: ${bounds.width}, height: ${bounds.height}');
      }
    } else {
      var totalWidth = 0;
      for (x in 0...columns.length) {
        for (y in 0...rows.length) {
          if (grid[y][x]) {
            totalWidth += columns[x];
            break;
          }
        }
      }
      bounds.width = totalWidth;

      if (smallestBounds != null) {
        trace('smallest area: ${smallestBounds.area()}, new area: ${bounds.area()}');
      }
      if (smallestBounds == null || bounds.area() < smallestBounds.area()) {
        smallestBounds = bounds.clone();
        smallestLayout = [];
        for (rect in placedRects) {
          smallestLayout.push(rect.clone());
        }
      }

      bounds.width -= 1;
      placedRects = [];
      placed = 0;
      grid = [[false]];
      columns = [bounds.width];
      rows = [bounds.height];
      trace('new width: ${bounds.width}, height: ${bounds.height}');
      if (bounds.width < biggestWidth) {
        done = true;
        trace('this is done');
      }
    }
  }

  function placeRect(rect: Rect): Bool {
    for (x in 0...columns.length) {
        for (y in 0...rows.length) {
          if (!grid[y][x]) {
            if (findPlace(x, y, rect)) {
              return true;
            }
          }
        }
    }

    return false;
  }

  function findPlace(x: Int, y: Int, rect: Rect): Bool {

    var xOffset = x;
    var yOffset = y;

    var totalWidth = columns[x];
    var totalHeight = rows[y];

    while (yOffset < rows.length) {
      if (grid[yOffset][xOffset]) {
        return false;
      }
      if (totalHeight >= rect.height) {
        break;
      }
      totalHeight += rows[yOffset];
      yOffset++;
    }

    if (yOffset >= rows.length) {
      return false;
    }

    while (xOffset < columns.length) {
      for (i in y...yOffset + 1) {
        if (grid[i][xOffset]) {
          return false;
        }
      }
      if (totalWidth >= rect.width) {
        break;
      }
      totalWidth += columns[xOffset];
      xOffset++;
    }

    if (xOffset >= columns.length) {
      return false;
    }

    insertRect(totalWidth, totalHeight, x, y, xOffset, yOffset, rect);

    return true;
  }

  function insertRect(totalWidth: Int, totalHeight: Int, x: Int, y: Int, xOffset: Int, yOffset: Int, rect: Rect) {
    var widthLeft = totalWidth - rect.width;
    var heightLeft = totalHeight - rect.height;

    if (heightLeft > 0) {
      rows[yOffset] = rows[yOffset] - heightLeft;
      rows.insert(yOffset + 1, heightLeft);
      insertRow(yOffset + 1);
    }

    if (widthLeft > 0) {
      columns[xOffset] = columns[xOffset] - widthLeft;
      columns.insert(xOffset + 1, widthLeft);
      insertColumn(xOffset + 1);
    }

    for (i in y...yOffset + 1) {
      for (j in x...xOffset + 1) {
        grid[i][j] = true;
      }
    }

    var xPos = 0;
    for (i in 0...x) {
      xPos += columns[i];
    }

    var yPos = 0;
    for (i in 0...y) {
      yPos += rows[i];
    }

    rect.x = xPos;
    rect.y = yPos;
  }

  function insertRow(index: Int) {
    var copy = grid[index - 1].copy();
    grid.insert(index, copy);
  }

  function insertColumn(index: Int) {
    for (row in grid) {
      row.insert(index, row[index - 1]);
    }
  }

  function sortByHeight() {
    rects.sort((a: Rect, b: Rect) -> {
      if (a.height > b.height) {
        return -1;
      } else if (a.height < b.height) {
        return 1;
      } else {
        return 0;
      }
    });
  }
}
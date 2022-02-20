package;

/**
 * Pack rectangles in bounds.
 * Optimized option is based on this post.
 * https://www.codeproject.com/Articles/210979/Fast-optimizing-rectangle-packing-algorithm-for-bu
 */
class Packer {
  var rects: Array<Rect>;

  var bounds: Rect;

  var placedRects: Array<Rect> = [];

  var gridRows: Array<Int> = [];
  var gridColumns: Array<Int> = [];

  var grid: Array<Array<Bool>> = [];

  var placed = 0;

  public var smallestBounds: Rect;

  public var smallestLayout: Array<Rect> = [];

  var biggestWidth = 0;

  var maxWidth: Int;

  var maxHeight: Int;

  var packMethod: PackMethod;

  public function new(rects: Array<Rect>, packMethod: PackMethod, maxWidth: Int, maxHeight: Int) {
    this.rects = rects;
    this.packMethod = packMethod;
    this.maxWidth = maxWidth;
    this.maxHeight = maxHeight;

    sortRects();
    setStartBounds();
    resetPlacements();
    pack();
  }

  function setStartBounds() {
    var boundsWidth = 0;
    var boundsHeight = 0;
    for (rect in rects) {
      if (boundsHeight == 0 || rect.height < boundsHeight) {
        boundsHeight = rect.height;
      }
      boundsWidth += rect.width;
      if (biggestWidth == 0 || rect.width > biggestWidth) {
        biggestWidth = rect.width;
      }
    }

    if (boundsWidth > maxWidth) {
      boundsWidth = maxWidth;
    }

    bounds = new Rect(0, 0, boundsWidth, boundsHeight);
  }

  function pack() {
    if (packMethod == BASIC) {
      if (!packRectangles()) {
        trace('Unable to fit the images inside the bounds.');
      }
    } else {
      var done = false;
      while (!done) {
        if (packRectangles()) {
          bounds.width -= 1;
          if (bounds.width < biggestWidth) {
            done = true;
            trace('packing complete.');
          }
          resetPlacements();
        } else {
          if (smallestBounds == null) {
            trace('unable to fit the images inside the bounds.');
          }
          done = true;
        }
      }
    }
  }

  function packRectangles(): Bool {
    while (placed < rects.length) {
      var rect = rects[placed];
      if (placeRect(rect)) {
        placedRects.push(rect);
        placed++;
      } else {
        bounds.height += rect.height;
        if (bounds.height > maxHeight) {
          return false;
        }
        resetPlacements();
      }
    }

    var totalWidth = 0;
    for (x in 0...gridColumns.length) {
      for (y in 0...gridRows.length) {
        if (grid[y][x]) {
          totalWidth += gridColumns[x];
          break;
        }
      }
    }

    bounds.width = totalWidth;
    if (smallestBounds == null || bounds.area() < smallestBounds.area()) {
      smallestBounds = bounds.clone();
      smallestLayout = [];
      for (rect in placedRects) {
        smallestLayout.push(rect.clone());
      }
    }
    
    return true;
  }

  function resetPlacements() {
      placedRects = [];
      placed = 0;
      grid = [[false]];
      gridColumns = [bounds.width];
      gridRows = [bounds.height];
  }

  /**
   * Add a rectangle into the grid.
   * @param rect The rectangle to add.
   * @return True if the the rectangle got placed.
   */
  function placeRect(rect: Rect): Bool {
    if (packMethod == BASIC) {
      for (row in 0...gridRows.length) {
        for (column in 0...gridColumns.length) {
          if (!grid[row][column]) {
            if (findPlace(column, row, rect)) {
              return true;
            }
          }
        }
      }
    } else {
      for (column in 0...gridColumns.length) {
        for (row in 0...gridRows.length) {
          if (!grid[row][column]) {
            if (findPlace(column, row, rect)) {
              return true;
            }
          }
        }
      }
    }

    return false;
  }


  /**
   * Find an empty spot for the rectangle as much left as possible.
   * @param startColumn The column to start checking.
   * @param startRow The row to start checking.
   * @param rect The rectangle to place.
   * @return True if the rectangle got placed.
   */
  function findPlace(startColumn: Int, startRow: Int, rect: Rect): Bool {
    var endColumn = startColumn;
    var endRow = startRow;
    var totalWidth = gridColumns[startColumn];
    var totalHeight = gridRows[startRow];

    // Check the rows down adding to the total height until the rectangle fits.
    while (endRow < gridRows.length) {
      // Cell not empty. The rectangle won't fit here.
      if (grid[endRow][endColumn]) {
        return false;
      }

      // The total height fits the rectangle.
      if (totalHeight >= rect.height) {
        break;
      }

      endRow++;
      if  (endRow < gridRows.length) {
        totalHeight += gridRows[endRow];
      }
    }

    // End row out of range of the rows. Rectangle doesn't fit here.
    if (endRow >= gridRows.length) {
      return false;
    }

    // Check the columns right of the start adding to the total width until the rectangle fits.
    while (endColumn < gridColumns.length) {
      for (y in startRow...endRow + 1) {
        if (grid[y][endColumn]) {
          return false;
        }
      }

      if (totalWidth >= rect.width) {
        break;
      }

      endColumn++;
      if (endColumn < gridColumns.length) {
        totalWidth += gridColumns[endColumn];
      }
    }

    if (endColumn >= gridColumns.length) {
      return false;
    }

    insertRect(totalWidth, totalHeight, startColumn, startRow, endColumn, endRow, rect);

    return true;
  }

  /**
   * Insert a rectangle into the grid.
   * @param totalWidth The width from the start column until the end column inclusive.
   * @param totalHeight The height from the start row until the end row inclusive.
   * @param startColumn The start column index.
   * @param startRow Then start row index.
   * @param endColumn The end column index.
   * @param endRow The end row index.
   * @param rect The rectangle to insert.
   */
  function insertRect(totalWidth: Int, totalHeight: Int, startColumn: Int, startRow: Int, endColumn: Int, endRow: Int, rect: Rect) {
    var widthLeft = totalWidth - rect.width;
    var heightLeft = totalHeight - rect.height;

    if (heightLeft > 0) {
      gridRows[endRow] = gridRows[endRow] - heightLeft;
      gridRows.insert(endRow + 1, heightLeft);
      insertRow(endRow + 1);
    }

    if (widthLeft > 0) {
      gridColumns[endColumn] = gridColumns[endColumn] - widthLeft;
      gridColumns.insert(endColumn + 1, widthLeft);
      insertColumn(endColumn + 1);
    }

    for (i in startRow...endRow + 1) {
      for (j in startColumn...endColumn + 1) {
        grid[i][j] = true;
      }
    }

    var xPos = 0;
    for (col in 0...startColumn) {
      xPos += gridColumns[col];
    }

    var yPos = 0;
    for (row in 0...startRow) {
      yPos += gridRows[row];
    }

    rect.x = xPos;
    rect.y = yPos;
  }

  /**
   * Insert a row into the packer grid.
   * @param index The position where you want to insert the row.
   */
  function insertRow(index: Int) {
    final copy = grid[index - 1].copy();
    grid.insert(index, copy);
  }

  /**
   * Insert a column into the packer grid.
   * @param index The position where you want to insert the column.
   */
  function insertColumn(index: Int) {
    for (row in grid) {
      row.insert(index, row[index - 1]);
    }
  }

  function sortRects() {
    if (packMethod == BASIC) {
      sortByName();
    } else {
      sortByHeight();
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

  function sortByName() {
    rects.sort((a: Rect, b: Rect) -> {
      if (a.name > b.name) {
        return 1;
      } else if (a.name < b.name) {
        return -1;
      } else {
        return 0;
      }
    });
  }
}
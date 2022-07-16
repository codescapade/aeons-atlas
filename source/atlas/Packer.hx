package atlas;

/**
 * Pack rectangles in bounds.
 * The optimal option is based on this post.
 * https://www.codeproject.com/Articles/210979/Fast-optimizing-rectangle-packing-algorithm-for-bu
 * 
 * Sort the rectangles by height, heighest first.
 * 
 * Make the bounds the width of the total width of all rectangles and the height the height of the highest rectangle.
 * 
 * There is a dynamic grid with booleans of where the placed rectangles are.
 * 
 * There is a separate array with all column widths and one with a row heights in the grid.
 * 
 * Each rectangle is inserted at the left most possible position.
 * 
 * The grid column and row that overlap the ends of the inserted rectangle get divided by the space left empty.
 * 
 * This is repeated until all rectangles are placed or one doesn't fit.
 * 
 * If one doesn't fit, increase the height of the bounds by the height of the rectangle that didn't fit and restart
 * the process.
 * 
 * If all fit make the bounds width smaller until it fits the rectangle exactly. If the area of the bounds this pass
 * is smaller that the current smallest bounds save it and the rectangle positions.
 * 
 * Subtract 1 pixels from the bounds width. if it is smaller than the width of the widest rectangle the process is
 * done. If not restart the process with the new bounds.
 */
class Packer {
  /**
   * All rectangles that need to be packed.
   */
  var rects: Array<Rect>;

  /**
   * The current bounds of the packer image.
   */
  var bounds: Rect;

  /**
   * A list of rectangles that have been placed on this pass.
   */
  var placedRects: Array<Rect> = [];

  /**
   * A list of row sizes for the dynamic grid in pixels.
   */
  var gridRows: Array<Int> = [];

  /**
   * A list of column sizes for the dynamci grid in pixels.
   */
  var gridColumns: Array<Int> = [];

  /**
   * Dynamic grid that has the filled and empty positions in the grid.
   */
  var grid: Array<Array<Bool>> = [];

  /**
   * The number of placed rectangles in the grid.
   */
  var placed = 0;

  /**
   * The current smallest bounds of the packed rectangles.
   */
  public var smallestBounds: Rect;

  /**
   * The layout of rectangles for the smallest bounds.
   */
  public var smallestLayout: Array<Rect> = [];

  /**
   * The width of the widest rectangle.
   */
  var biggestWidth = 0;

  /**
   * The maximum width the bounds can be.
   */
  var maxWidth: Int;

  /**
   * The maximum height the bounds can be.
   */
  var maxHeight: Int;

  /**
   * Simple or optimal packing method depending on the atlas config.
   */
  var packMethod: PackMethod;

  /**
   * Constructor.
   * @param rects The rectangles to pack in the atlas.
   * @param packMethod The method to use for the packing.
   * @param maxWidth The maximum width of the atlas in pixels.
   * @param maxHeight The maximum height of the atlas in pixels.
   */
  public function new(rects: Array<Rect>, packMethod: PackMethod, maxWidth: Int, maxHeight: Int) {
    this.rects = rects;
    this.packMethod = packMethod;
    this.maxWidth = maxWidth;
    this.maxHeight = maxHeight;

    sortRects();
    setStartBounds();
    resetPlacements();
  }

  /**
   * Pack the rectangles.
   */
  public function pack(): Bool {
    if (packMethod == BASIC) {
      if (!packRectangles()) {
        #if !unit_testing
        Sys.println('Error: Unable to fit the images inside the bounds.');
        #end
        return false;
      }
      return true;
    } else {
      var success = true;
      var done = false;
      while (!done) {
        if (packRectangles()) {
          bounds.width -= 1;
          if (bounds.width < biggestWidth) {
            done = true;
          } else {
            resetPlacements();
          }
        } else {
          if (smallestBounds == null) {
            #if !unit_testing
            Sys.println('Error: Unable to fit the images inside the bounds.');
            #end
            success = false;
          }
          done = true;
        }
      }

      return success;
    }
  }

  /**
   * Set the bounds for the first pass.
   */
  function setStartBounds() {
    var boundsWidth = 0;
    var boundsHeight = 0;
    for (rect in rects) {
      if (boundsHeight == 0 || rect.height > boundsHeight) {
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

  /**
   * Run a packing pass.
   * @return True if all rectangles fit.
   */
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

    // Find the width of of the packed rectangles to decrease the bounds width.
    var totalWidth = 0;
    for (x in 0...gridColumns.length) {
      for (y in 0...gridRows.length) {
        if (grid[y][x]) {
          totalWidth += gridColumns[x];
          break;
        }
      }
    }

    // Update the smallest bounds.
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

  /**
   * Reset for a new pass.
   */
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
      // Find top most empty spot.
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
      // Find left most empty spot.
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
      if (endRow < gridRows.length) {
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
  function insertRect(totalWidth: Int, totalHeight: Int, startColumn: Int, startRow: Int, endColumn: Int, endRow: Int,
      rect: Rect) {
    final widthLeft = totalWidth - rect.width;
    final heightLeft = totalHeight - rect.height;

    // Divide the grid row that contains the last part of the new rect.
    if (heightLeft > 0) {
      gridRows[endRow] = gridRows[endRow] - heightLeft;
      gridRows.insert(endRow + 1, heightLeft);
      insertRow(endRow + 1);
    }

    // Divide the grid column that contains the last part of the new rect.
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

package;

import haxe.io.Bytes;

class Image {

  public var width(default, null): Int;

  public var height(default, null): Int;

  var bytes: Bytes;

  final stride = 4;

  public function new(width: Int, height: Int, bytes: Bytes = null, trim = false, extrude = 0) {
    this.width = width;
    this.height = height;

    this.bytes = Bytes.alloc(width * height * stride);
    if (bytes == null) {
      this.bytes.fill(0, width * height * stride, 0);
    } else {
      this.bytes.blit(0, bytes, 0, bytes.length);
      if (trim) {
        trimTransparentPixels();
      }

      if (extrude > 0) {
        extrudeEdges(extrude);
      }
    }
  }

  public function insertImage(image: Image, xPos: Int, yPos: Int) {
    for (y in 0...image.height) {
      for (x in 0...image.width) {
        setPixel(xPos + x, yPos + y, image.getPixel(x, y));
      }
    }
  }

  public function getPixels(): Bytes {
    return bytes;
  }

  public function getPixel(x: Int, y: Int, ?out: Color): Color {
    if (out == null) {
      out = new Color(0, 0, 0, 0);
    }

    var start = (y * width + x) * stride;
    out.a = bytes.get(start);
    out.r = bytes.get(start + 1);
    out.g = bytes.get(start + 2);
    out.b = bytes.get(start + 3);

    return out;
  }

  public function setPixel(x: Int, y: Int, color: Color) {
    var start = (y * width + x) * stride;
    bytes.set(start, color.a);
    bytes.set(start + 1, color.r);
    bytes.set(start + 2, color.g);
    bytes.set(start + 3, color.b);
  }

  function extrudeEdges(amount: Int) {
    var original = new Image(width, height, bytes);

    width += amount * 2;
    height += amount * 2;
    var size = width * height * stride;
    bytes = Bytes.alloc(size);
    bytes.fill(0, stride, 0);
    insertImage(original, amount, amount);

    var color = new Color(0, 0, 0, 0);
    
    for (y in amount...original.height + amount) {
      // Extrude the left.
      getPixel(amount, y, color);
      for (x in 0...amount) {
        setPixel(x, y, color);
      }

      // Extrude the right.
      getPixel(width - amount - 1, y, color);
      for (x in width - amount - 1...width) {
        setPixel(x, y, color);
      }
    }

    for (x in amount...original.width + amount) {
      // Extrude the top.
      getPixel(x, amount, color);
      for (y in 0...amount) {
        setPixel(x, y, color);
      }

      // Extrude the bottom.
      getPixel(x, height - amount - 1, color);
      for (y in height - amount - 1...height) {
        setPixel(x, y, color);
      }
    }
  }

  function trimTransparentPixels() {
    var temp = new Image(width, height, this.bytes);

    var leftOffset = 0;
    var rightOffset = 0;
    var topOffset = 0;
    var bottomOffset = 0;

    for (x in 0...width) {
      if (!isColumnEmpty(temp, x)) {
        break;
      }
      leftOffset++;
    }

    var x = width - 1;
    while (x >= 0) {
      if (!isColumnEmpty(temp, x)) {
        break;
      }
      rightOffset++;
      x--;
    }

    for (y in 0...height) {
      if (!isRowEmpty(temp, y)) {
        break; 
      }
      topOffset++;
    }

    var y = height - 1;
    while (y >= 0) {
      if (!isRowEmpty(temp, y)) {
        break;
      }
      bottomOffset++;
      y--;
    }

    width = temp.width - leftOffset - rightOffset;
    height = temp.height - topOffset - bottomOffset;

    bytes = Bytes.alloc(width * height * stride);
    var pos = 0;
    var color = new Color(0, 0, 0, 0);
    for (y in topOffset...topOffset + height) {
      for (x in leftOffset...leftOffset + width) {
        temp.getPixel(x, y, color);
        bytes.set(pos, color.a);
        bytes.set(pos + 1, color.r);
        bytes.set(pos + 2, color.g);
        bytes.set(pos + 3, color.b);
        pos += stride;
      }
    }
  }

  function isColumnEmpty(image: Image, column: Int): Bool {
    for (y in 0...image.height) {
      if (image.getPixel(column, y).a != 0) {
        return false;
      }
    }

    return true;
  }

  function isRowEmpty(image: Image, row: Int): Bool {
    for (x in 0...image.width) {
      if (image.getPixel(x, row).a != 0) {
        return false;
      }
    }

    return true;
  }
}
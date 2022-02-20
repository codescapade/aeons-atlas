package;

import sys.io.File;
import haxe.io.Bytes;

class Image {

  public var width(default, null): Int;

  public var height(default, null): Int;

  public var trimmed(default, null): Bool;

  public var extrude(default, null): Int;

  public var sourceWidth(default, null): Int;

  public var sourceHeight(default, null): Int;

  public var xOffset(default, null) = 0;

  public  var yOffset(default, null) = 0;

  var bytes: Bytes;

  final stride = 4;

  public static function fromFile(path: String, trim: Bool, extrude: Int): Image {
    var file = File.read(path);
    var data = new format.png.Reader(file).read();
    var pixelData = format.png.Tools.extract32(data);
    format.png.Tools.reverseBytes(pixelData);
    var header = format.png.Tools.getHeader(data);

    return new Image(header.width, header.height, pixelData, trim, extrude);
  }

  public function new(width: Int, height: Int, bytes: Bytes = null, trim = false, extrude = 0) {
    this.width = width;
    this.height = height;
    this.sourceWidth = width;
    this.sourceHeight = height;
    this.trimmed = trim;
    this.extrude = extrude;

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

  public function getPixel(x: Int, y: Int): Color {
    var start = (y * width + x) * stride;

    return return new Color(bytes.get(start), bytes.get(start + 1), bytes.get(start + 2), bytes.get(start + 3));
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
    var color: Color;
    for (y in amount...original.height + amount) {
      // Extrude the left.
      color = getPixel(amount, y);
      for (x in 0...amount) {
        setPixel(x, y, color);
      }

      // Extrude the right.
      color = getPixel(width - amount - 1, y);
      for (x in width - amount - 1...width) {
        setPixel(x, y, color);
      }
    }

    for (x in amount...original.width + amount) {
      // Extrude the top.
      color = getPixel(x, amount);
      for (y in 0...amount) {
        setPixel(x, y, color);
      }

      // Extrude the bottom.
      color = getPixel(x, height - amount - 1);
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

    xOffset = leftOffset;
    yOffset = topOffset;
    width = temp.width - leftOffset - rightOffset;
    height = temp.height - topOffset - bottomOffset;

    bytes = Bytes.alloc(width * height * stride);
    var pos = 0;
    var color: Color;
    for (y in topOffset...topOffset + height) {
      for (x in leftOffset...leftOffset + width) {
        color = temp.getPixel(x, y);
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
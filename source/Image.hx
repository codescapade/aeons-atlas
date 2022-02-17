package;

import haxe.io.Bytes;

class Image {

  public var width(default, null): Int;

  public var height(default, null): Int;

  var bytes: Bytes;

  final stride = 4;

  public function new(width: Int, height: Int, bytes: Bytes = null, extrude = 0) {
    this.width = width;
    this.height = height;

    if (bytes == null) {
      this.bytes = Bytes.alloc(width * height * stride);
      this.bytes.fill(0, width * height * stride, 0);
    } else if (extrude > 0) {
      extrudeEdges(bytes, width, height, extrude);
    } else {
      this.bytes = bytes;
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

  function extrudeEdges(bytes: Bytes, width: Int, height: Int, amount: Int) {
    this.width = width + amount * 2;
    this.height = height + amount * 2;
    var size = this.width * this.height * stride;
    this.bytes = Bytes.alloc(size);
    this.bytes.fill(0, stride, 0);
    var original = new Image(width, height, bytes);
    insertImage(original, amount, amount);

    var color = new Color(0, 0, 0, 0);
    for (y in amount...height + amount) {
      getPixel(amount, y, color);
      for (x in 0...amount) {
        setPixel(x, y, color);
      }
      getPixel(this.width - amount - 1, y, color);
      for (x in this.width - amount - 1...this.width) {
        setPixel(x, y, color);
      }
    }

    for (x in amount...width + amount) {
      getPixel(x, amount, color);
      for (y in 0...amount) {
        setPixel(x, y, color);
      }
      getPixel(x, this.height - amount - 1, color);
      for (y in this.height - amount - 1...this.height) {
        setPixel(x, y, color);
      }
    }
  }
}
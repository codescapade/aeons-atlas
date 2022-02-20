package;

class Rect {

  public final name: String;

  public var x: Int;

  public var y: Int;

  public var width: Int;

  public var height: Int;

  public function new(x: Int, y: Int, width: Int, height: Int, name = '') {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.name = name;
  }

  public function clone(): Rect {
    return new Rect(x, y, width, height, name);
  }

  public function area(): Int {
    return width * height;
  }
}
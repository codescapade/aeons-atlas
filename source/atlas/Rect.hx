package atlas;

/**
 * Rectangle class.
 */
class Rect {
  /**
   * Filename of the image this rectangle belongs to.
   */
  public final name: String;

  /**
   * The x position of the rectangle in pixels.
   */
  public var x: Int;

  /**
   * The y position of the rectangle in pixels.
   */
  public var y: Int;

  /**
   * The width of the rectangle in pixels.
   */
  public var width: Int;

  /**
   * The height of the rectangle in pixels.
   */
  public var height: Int;

  /**
   * Constructor.
   * @param x The x position.
   * @param y The y position.
   * @param width The width.
   * @param height The height.
   * @param name Optional filename.
   */
  public function new(x: Int, y: Int, width: Int, height: Int, name = '') {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.name = name;
  }

  /**
   * Clone this rectangle into a new one.
   * @return The new rectangle.
   */
  public function clone(): Rect {
    return new Rect(x, y, width, height, name);
  }

  /**
   * Calculate the area of this rectangle.
   * @return The area in pixels.
   */
  public function area(): Int {
    return width * height;
  }
}

package atlas;

/**
 * ARGB color class to make working with pixels easier.
 */
class Color {
  /**
   * Alpha byte.
   */
  public final a: Int;

  /**
   * Red byte.
   */
  public final r: Int;

  /**
   * Green byte.
   */
  public final g: Int;

  /**
   * Blue byte.
   */
  public final b: Int;

  /**
   * Constructor.
   * @param a Alpha byte.
   * @param r Red byte.
   * @param g Green byte.
   * @param b Blue byte.
   */
  public function new(a: Int, r: Int, g: Int, b: Int) {
    this.a = a;
    this.r = r;
    this.g = g;
    this.b = b;
  }

  /**
   * Check if another color is the same as this.
   * @param other The color to compare to.
   * @return Bool
   */
  public function equals(other: Color): Bool {
    return a == other.a && r == other.r && g == other.g && b == other.b;
  }
}

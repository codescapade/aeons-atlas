package atlas;

/**
 * This is a frame in the json data.
 * It uses the generic texturepacker format so it should be easy
 * to use in other engines.
 */
typedef Frame = {
  /**
   * The name you can use to get the frame.
   */
  var filename: String;

  /**
   * The rectangle position and size of the frame in the atlas image.
   */
  var frame: {
    /**
     * The x position in pixels.
     */
    x: Int,

    /**
     * The y position in pixels.
     */
    y: Int,

    /**
     * The width in pixels.
     */
    w: Int,

    /**
     * The height in pixels.
     */
    h: Int
  };

  /**
   * This is always false because images are never stored rotated.
   */
  var rotated: Bool;

  /**
   * Are the transparent parts of the image trimmed off.
   */
  var trimmed: Bool;

  /**
   * The size before trimming.
   */
  var spriteSourceSize: {
    /**
     * Always 0.
     */
    x: Int,

    /**
     * Always 0.
     */
    y: Int,

    /**
     * The width in pixels.
     */
    w: Int,

    /**
     * The height in pixels.
     */
    h: Int
  };

  /**
   * The size of the image before trimming.
   */
  var sourceSize: {
    /**
     * The width in pixels.
     */
    w: Int,

    /**
     * The height in pixels.
     */
    h: Int
  };
}

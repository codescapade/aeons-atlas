package;

typedef Config = {
  /**
   * The name of the image and data files.
   */
  var name: String;

  /**
   * The folder to store the atlas in relative to the config file.
   */
  var saveFolder: String;

  /**
   * A list of folders with images you want to add to the atlas relative to the config file. Not recursive.
   */
  var ?folders: Array<String>;

  /**
   * A list of image files you want to add to the atlas relative to the config file.
   */
  var ?files: Array<String>;

  /**
   * Should the transparent pixels around the images be removed where possible to save space in the atlas.
   */
  var ?trimmed: Bool;

  /**
   * The amount of pixels to extrude out from the edge of the images. This helps with flickering on the edge of sprites.
   * Especially in tilemaps.
   */
  var ?extrude: Int;

  /**
   * The method to use for packing the sprites.
   * Options:
   * - optimal - The smallest atlas possible.
   * - basic - Sort alphabetically and just add them in the fastest way.
   */
  var ?packMethod: PackMethod;

  /**
   * Should the folder name be included in the name of the sprite in the data file.
   * For when you use duplicate names in separate folders.
   */
  var ?folderInName: Bool;

  /**
   * The maximum width of the atlas image in pixels.
   */
  var ?maxWidth: Int;

  /**
   * The maximum height of the atlas image in pixels.
   */
  var ?maxHeight: Int;

  /**
   * Export only the image file.
   */
  var ?noData: Bool;
}
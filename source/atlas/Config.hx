package atlas;

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

/**
 * Helper to load the configs from the json file.
 */
typedef AtlasConfig = {
  var atlas: Array<Config>;
}

/**
 * Set default values for each config for the optional fields if they are null.
 * @param data All configs.
 */
function setDefaultConfigValues(data: AtlasConfig) {
  for (config in data.atlas) {
    if (config.folders == null) {
      config.folders = [];
    }

    if (config.files == null) {
      config.files = [];
    }

    if (config.trimmed == null) {
      config.trimmed = true;
    }

    if (config.extrude == null) {
      config.extrude = 1;
    }

    if (config.packMethod == null) {
      config.packMethod = OPTIMAL;
    }

    if (config.folderInName == null) {
      config.folderInName = false;
    }

    if (config.maxWidth == null) {
      config.maxWidth = 4096;
    }

    if (config.maxHeight == null) {
      config.maxHeight = 4096;
    }

    if (config.noData == null) {
      config.noData = false;
    }
  }
}

import haxe.Json;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

class Main {

  static function main() {
    // The program can take an optional folder that contains an atlas.json.
    final args = Sys.args();
    final configPath = args.length > 0 ? Path.join([args[0], 'atlas.json']) : 'atlas.json';
    final fullPath = Path.join([Sys.getCwd(), configPath]);

    // Set the working directory to the atlas.json folder to make it easier to get relative paths for the images.
    Sys.setCwd(Path.directory(fullPath));

    // Load the atlas.json config data.
    final jsonString = File.getContent(fullPath);
    final configData: ConfigData = Json.parse(jsonString);
    setDefaultConfigValues(configData);

    // Create the atlases for each config in the file.
    for (config in configData.configs) {
      final atlas = new Atlas(config);

      if (!atlas.pack()) {
        Sys.println('Unable to pack the atlas.');
      }

      // Create the save folder if it does not exist.
      final saveFolder = Path.join([Sys.getCwd(), config.saveFolder]);
      if (!FileSystem.exists(saveFolder)) {
        FileSystem.createDirectory(saveFolder);
      }

      Save.atlasImage(config.name, saveFolder, atlas);

      if (!config.noData) {
        Save.jsonData(config.name, saveFolder, atlas);
      }
    }
  }

  /**
   * Set default values for each config for the optional fields if they are null.
   * @param data All configs.
   */
  static function setDefaultConfigValues(data: ConfigData) {
    for (config in data.configs) {
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
}

/**
 * Helper to load the configs from the json file.
 */
typedef ConfigData = {
  var configs: Array<Config>;
}
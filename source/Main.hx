package;

import haxe.Json;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

import atlas.Atlas;
import atlas.Config;
import atlas.Save;

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
        Sys.println('Unable to pack atlas ${config.name}.');
        continue;
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
}
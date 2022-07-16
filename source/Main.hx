package;

import atlas.Atlas;
import atlas.Config;
import atlas.Save;

import haxe.io.Path;

import haxetoml.TomlParser;

import sys.FileSystem;
import sys.io.File;

class Main {
  static function main() {
    // The program can take an optional path to a .toml config file.
    final args = Sys.args();

    final configPath = args.length > 0 ? args[0] : 'atlas.toml';
    final fullPath = Path.join([Sys.getCwd(), configPath]);

    // Set the working directory to the folder of the .toml file to make it easier to get relative paths for the images.
    Sys.setCwd(Path.directory(fullPath));

    // Load the atlas.json config data.
    final tomlString = File.getContent(fullPath);
    final atlasConfig: AtlasConfig = TomlParser.parseString(tomlString, {});

    setDefaultConfigValues(atlasConfig);

    // Create the atlases for each config in the file.
    for (config in atlasConfig.atlas) {
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

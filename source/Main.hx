import sys.FileSystem;
import haxe.Json;
import format.png.Writer;
import sys.io.File;
import haxe.io.Path;
import format.png.Tools;
import config.ConfigData;

class Main {

  static function main() {
    final args = Sys.args();
    final configPath = args.length > 0 ? Path.join([args[0], 'atlas.json']) : 'atlas.json';
    final path = Path.join([Sys.getCwd(), configPath]);

    final p = new Path(path);
    Sys.setCwd(p.dir);

    final jsonString = File.getContent(path);
    final configData: ConfigData = Json.parse(jsonString);
    setDefaultValues(configData);

    for (config in configData.configs) {
      var atlas = new Atlas(config);
      var saveFolder = Path.join([Sys.getCwd(), config.saveFolder]);
      if (!FileSystem.exists(saveFolder)) {
        FileSystem.createDirectory(saveFolder);
      }
      saveAtlasImage(config.name, saveFolder, atlas);

      if (!config.noData) {
        saveJsonData(config.name, saveFolder, atlas);
      }
    }
  }

  static function saveAtlasImage(name: String, saveFolder: String, atlas: Atlas) {
    var bytes = atlas.finalImage.getPixels();
    var saveData = Tools.build32ARGB(atlas.finalImage.width, atlas.finalImage.height, bytes);
    var path = Path.join([saveFolder, '${name}.png']);
    var file = File.write(path);
    var writer = new Writer(file);
    writer.write(saveData);
    file.close();
  }

  static function saveJsonData(name: String, saveFolder: String, atlas: Atlas) {
    var frames: Array<Frame> = [];
    for (rect in atlas.finalRects) {
      var image = atlas.images[rect.name];
      frames.push({
        filename: rect.name,
        frame: {
          x: rect.x + image.extrude,
          y: rect.y + image.extrude,
          w: rect.width - image.extrude * 2,
          h: rect.height - image.extrude * 2
        },
        rotated: false,
        trimmed: image.trimmed,
        spriteSourceSize: {
          x: 0,
          y: 0,
          w: image.sourceWidth,
          h: image.sourceHeight
        },
        sourceSize: {
          w: image.sourceWidth,
          h: image.sourceHeight
        }
      });
    }

    var data: JsonData = {
      frames: frames
    };

    var path = Path.join([saveFolder, '${name}.json']);
    var content = Json.stringify(data, '  ');
    File.saveContent(path, content);
  }
}

typedef JsonData = {
  var frames: Array<Frame>;
}

typedef Frame = {
  var filename: String;
  var frame: { x: Int, y: Int, w: Int, h: Int };
  var rotated: Bool;
  var trimmed: Bool;
  var spriteSourceSize: { x: Int, y: Int, w: Int, h: Int };
  var sourceSize: { w: Int, h: Int };
}
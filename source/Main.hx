import haxe.Json;
import format.png.Reader;
import format.png.Writer;
import sys.io.File;
import haxe.io.Path;
import format.png.Tools;
import haxe.io.Bytes;
import config.ConfigData;

class Main {

  static function main() {
    final args = Sys.args();
    final configPath = args.length > 0 ? args[0] : 'atlas.json';
    final path = Path.join([Sys.getCwd(), configPath]);

    final p = new Path(path);
    Sys.setCwd(p.dir);

    final jsonString = File.getContent(path);
    final configData: ConfigData = Json.parse(jsonString);
    setDefaultValues(configData);

    for (config in configData.configs) {
      var atlas = new Atlas(config);
      var bytes = atlas.finalImage.getPixels();
      var saveData = Tools.build32ARGB(atlas.finalImage.width, atlas.finalImage.height, bytes);
      var path = Path.join([Sys.getCwd(), 'test.png']);
      var file = File.write(path);
      var writer = new Writer(file);
      writer.write(saveData);
      file.close();
    }

    // readImage();
  }

  static function saveRedBlock() {
    final width = 32;
    final height = 32;
    
    final pixels = width * height;
    var bytes = Bytes.alloc(pixels * 4);

    // Make it argb.
    for (i in 0...pixels) {
      bytes.set(i * 4, 255);
      bytes.set(i * 4 + 1, 255);
      bytes.set(i * 4 + 2, 0);
      bytes.set(i * 4 + 3, 0);
    }

    var data = Tools.build32ARGB(width, height, bytes);
    var path = Path.join([Sys.getCwd(), 'test.png']);
    var file = File.write(path);
    var writer = new Writer(file);
    writer.write(data);
    file.close();
  }

  static function readImage(): Void {
    var file = File.read(Path.join([Sys.getCwd(), 'blue_box.png']));
    var data = new Reader(file).read();
    var pixelData = Tools.extract32(data);
    Tools.reverseBytes(pixelData);
    var header = Tools.getHeader(data);
    var boxImage = new Image(header.width, header.height, pixelData, true, 1);
    
    // var newImage = new Image(100, 100);
    // newImage.insertImage(boxImage, 0, 0);

    // var bytes = newImage.getPixels();
    // var saveData = Tools.build32ARGB(newImage.width, newImage.height, bytes);
    var bytes = boxImage.getPixels();
    var saveData = Tools.build32ARGB(boxImage.width, boxImage.height, bytes);
    var path = Path.join([Sys.getCwd(), 'test.png']);
    var file = File.write(path);
    var writer = new Writer(file);
    writer.write(saveData);
    file.close();
  }
}
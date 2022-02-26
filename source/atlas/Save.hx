package atlas;

import haxe.Json;
import haxe.io.Path;
import sys.io.File;

/**
 * Helper class to save the image and json data of the atlas.
 */
class Save {

  /**
   * Save the atlas image to a png file.
   * @param name The name of the file.
   * @param saveFolder The folder to save to.
   * @param atlas The created atlas.
   */
  public static function atlasImage(name: String, saveFolder: String, atlas: Atlas) {
    final bytes = atlas.packedImage.getPixels();
    final saveData = format.png.Tools.build32ARGB(atlas.packedImage.width, atlas.packedImage.height, bytes);
    final path = Path.join([saveFolder, '${name}.png']);
    final file = File.write(path);
    final writer = new format.png.Writer(file);
    writer.write(saveData);
    file.close();
  }

  /**
   * Save the json data to a file.
   * @param name The name of the file.
   * @param saveFolder The folder to save to.
   * @param atlas created atlas.
   */
  public static function jsonData(name: String, saveFolder: String, atlas: Atlas) {
    var frames: Array<Frame> = [];

    // Use the atlas rectangles to construct the json data.
    for (rect in atlas.packedRects) {
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

    var path = Path.join([saveFolder, '${name}.json']);
    var content = Json.stringify({ frames: frames }, '  ');
    File.saveContent(path, content);
  }
}
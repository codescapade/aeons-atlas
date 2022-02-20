package;

import haxe.io.Path;
import sys.FileSystem;
import config.Config;

class Atlas {
  public var finalImage: Image;

  public var finalRects: Array<Rect>;

  public final images = new Map<String, Image>();

  public function new(config: Config) {
    var imagePaths: Array<ImagePath> = [];

    if (config.folders != null) {
      for (folder in config.folders) {
        var fullPath = Path.join([Sys.getCwd(), folder]);
        if (FileSystem.isDirectory(fullPath)) {
          var paths = getAllImagePathsFromAFolder(fullPath);
          imagePaths = imagePaths.concat(paths);
        } else {
          trace('folder ${fullPath} does not exist');
        }
      }
    }

    if (config.files != null) {
      for (file in config.files) {
        var fullPath = Path.join([Sys.getCwd(), file]);
        var path = getFullImagePath(fullPath);
        if (path != null) {
          imagePaths.push(path);
        }
      }
    }

    var rects: Array<Rect> = [];
    for (path in imagePaths) {
      var name = config.folderInName ? '${path.folderName}_ ${path.fileName}' : ${path.fileName};
      var image = Image.fromFile(path.fullPath, config.trimmed, config.extrude);
      images[name] = image;
      rects.push(new Rect(0, 0, image.width, image.height, name));
    }

    var packer = new Packer(rects, config.packMethod, config.maxWidth, config.maxHeight);

    finalImage = new Image(packer.smallestBounds.width, packer.smallestBounds.height);
    for (rect in packer.smallestLayout) {
      finalImage.insertImage(images[rect.name], rect.x, rect.y);
    }
    finalRects = packer.smallestLayout;
  }

  function getAllImagePathsFromAFolder(folder: String): Array<ImagePath> {
    var files = FileSystem.readDirectory(folder);
    var imagePaths: Array<ImagePath> = [];
    for (file in files) {
      var path = getFullImagePath(Path.join([folder, file]));
      if (path != null) {
        imagePaths.push(path);
      }
    }

    return imagePaths;
  }

  function getFullImagePath(path: String): ImagePath {
    var p = new Path(path);
    if (p.ext == 'png') {
      var separator = p.backslash ? '\\' : '/';
      var folders = p.dir.split(separator);
      var folder = folders[folders.length - 1];
      return {
        fullPath: path,
        folderName: folder,
        fileName: p.file
      };
    } else {
      trace('${path} is not a png image');
      return null;
    }
  }
}
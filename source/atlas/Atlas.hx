package atlas;

import haxe.io.Path;
import sys.FileSystem;

/**
 * The sprite atlas class.
 */
class Atlas {
  /**
   * The final packed image.
   */
  public var packedImage(default, null): Image;

  /**
   * The final packed image positions inside the atlas.
   */
  public var packedRects(default, null): Array<Rect>;

  /**
   * The images that are in the atlas.
   */
  public final images = new Map<String, Image>();

  /**
   * The start rectangles.
   */
  public var rects(default, null): Array<Rect>;

  /**
   * The file paths to the images.
   */
  var imagePaths: Array<ImagePath> = [];

  /**
   * Atlas.json configuration.
   */
  var config: Config;

  /**
   * Used to don't pack if the constructor found issues.
   */
  var errorFound = false;

  /**
   * Constructor.
   * @param config Atlas config.
   */
  public function new(config: Config) {
    this.config = config;

    // Get all the png images from the folders in the config. This is not recursive.
    if (config.folders != null) {
      for (folder in config.folders) {
        final fullPath = Path.join([Sys.getCwd(), folder]);
        if (FileSystem.isDirectory(fullPath)) {
          final paths = getAllImagePathsFromAFolder(fullPath);
          imagePaths = imagePaths.concat(paths);
        } else {
          Sys.println('Error: folder ${fullPath} does not exist.');
          errorFound = true;
          return;
        }
      }
    }

    // Get all the png images from the files in the config.
    if (config.files != null) {
      for (file in config.files) {
        final fullPath = Path.join([Sys.getCwd(), file]);
        final imagePath = getFullImagePath(fullPath);
        if (imagePath != null) {
          imagePaths.push(imagePath);
        }
      }
    }

    var duplicates = false;

    final names: Array<String> = [];
    rects = [];
    for (path in imagePaths) {
      final name = config.folderInName ? '${path.folderName}_${path.fileName}' : ${path.fileName};

      // Check for duplicates.
      if (names.indexOf(name) == -1) {
        names.push(name);
      } else {
        duplicates = true;
        Sys.println('Error: "${name}" already exists. Cannot have duplicate names.');
      }

      // Load the image and create the rectangle.
      final image = Image.fromFile(path.fullPath, config.trimmed, config.extrude);
      images[name] = image;
      rects.push(new Rect(0, 0, image.width, image.height, name));
    }

    if (duplicates) {
      if (!config.folderInName) {
        Sys.println('Error: Duplicate image names found. Try using the "folderInName" config option.');
      }
      errorFound = true;
    }
  }

  /**
   * Pack the images into one image.
   * @return True if the packing was successful.
   */
  public function pack(): Bool {
    if (errorFound) {
      return false;
    }

    // This does the actual packing.
    final packer = new Packer(rects, config.packMethod, config.maxWidth, config.maxHeight);
    if (!packer.pack()) {
      return false;
    }

    // Create the final blank image with the correct size.
    packedImage = new Image(packer.smallestBounds.width, packer.smallestBounds.height);

    // Add all images into the final image.
    for (rect in packer.smallestLayout) {
      packedImage.insertImage(images[rect.name], rect.x, rect.y);
    }
    packedRects = packer.smallestLayout;

    #if !unit_testing
    Sys.println('Atlas "${config.name}" has been packed.');
    #end

    return true;
  }

  /**
   * Loop through a folder and get all png paths.
   * @param folder The path of the folder.
   * @return A list of paths.
   */
  function getAllImagePathsFromAFolder(folder: String): Array<ImagePath> {
    final files = FileSystem.readDirectory(folder);
    final imagePaths: Array<ImagePath> = [];
    for (file in files) {
      final path = getFullImagePath(Path.join([folder, file]));
      if (path != null) {
        imagePaths.push(path);
      }
    }

    return imagePaths;
  }

  /**
   * Create a path with direct parent folder name and a file name for easy use later.
   * @param path The path string.
   * @return The created ImagePath.
   */
  function getFullImagePath(path: String): ImagePath {
    final p = new Path(path);
    if (p.ext == 'png') {
      final separator = p.backslash ? '\\' : '/';
      final folders = p.dir.split(separator);

      // Get the direct parent folder of the image.
      final folder = folders[folders.length - 1];

      return {
        fullPath: path,
        folderName: folder,
        fileName: p.file
      };
    } else {
      Sys.println('${path} is not a png image');

      return null;
    }
  }
}
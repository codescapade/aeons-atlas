package atlas;

import haxe.Json;
import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;

import buddy.BuddySuite;

using buddy.Should;


class SaveTest extends BuddySuite {

  public function new() {
    describe('Save', {

      var config: Config;

      var savedFrames: Array<Frame>;

      beforeAll({
        config = {
          name: 'test',
          saveFolder: 'tests/out',
          folders: [
            'tests/testFiles'
          ],
          trimmed: true,
          extrude: 1,
          maxWidth: 4096,
          maxHeight: 4096,
          noData: false
        };
        savedFrames = createSavedFrames();
      });

      beforeEach({
        FileSystem.createDirectory('tests/out');
      });

      afterEach({
        final folder = 'tests/out';
        if (FileSystem.exists(folder)) {
          var files = FileSystem.readDirectory(folder);
          for (file in files) {
            FileSystem.deleteFile(Path.join([folder, file]));
          }
          FileSystem.deleteDirectory(folder);
        }
      });

      it('Should save the packed image.', {
        var atlas = new Atlas(config);
        var success = atlas.pack();

        success.should.be(true);

        Save.atlasImage(config.name, config.saveFolder, atlas);

        var imageExists = FileSystem.exists('tests/out/test.png');
        imageExists.should.be(true);
      });

      it('Should save the data file.', {
        var atlas = new Atlas(config);
        var success = atlas.pack();

        success.should.be(true);

        Save.jsonData(config.name, config.saveFolder, atlas);

        var jsonExists = FileSystem.exists('tests/out/test.json');
        jsonExists.should.be(true);

        var jsonString = File.getContent('tests/out/test.json');
        var frameData: Frames = Json.parse(jsonString);
        frameData.frames.length.should.be(6);

        // Check if the json data was saved correctly.
        for (index => frame in frameData.frames) {
          framesEqual(frame, savedFrames[index]).should.be(true);
        }
      });
    });
  }

  static function createSavedFrames(): Array<Frame> {
    return [
      {
        rotated: false,
        sourceSize: {
          h: 90,
          w: 70
        },
        frame: {
          h: 72,
          x: 1,
          y: 1,
          w: 36
        },
        trimmed: true,
        spriteSourceSize: {
          h: 90,
          x: 16,
          y: 11,
          w: 70
        },
        filename: 'green_box'
      },
      {
        rotated: false,
        sourceSize: {
          h: 72,
          w: 54
        },
        frame: {
          h: 64,
          x: 39,
          y: 1,
          w: 18
        },
        trimmed: true,
        spriteSourceSize: {
          h: 72,
          x: 19,
          y: 4,
          w: 54
        },
        filename: 'orange_box'
      },
      {
        rotated: false,
        sourceSize: {
          h: 100,
          w: 86
        },
        frame: {
          h: 52,
          x: 39,
          y: 67,
          w: 72
        },
        trimmed: true,
        spriteSourceSize: {
          h: 100,
          x: 7,
          y: 33,
          w: 86
        },
        filename: 'yellow_box'
      },
      {
        rotated: false,
        sourceSize: {
          h: 64,
          w: 96
        },
        frame: {
          h: 48,
          x: 59,
          y: 1,
          w: 72
        },
        trimmed: true,
        spriteSourceSize: {
          h: 64,
          x: 13,
          y: 10,
          w: 96
        },
        filename: 'red_box'
      },
      {
        rotated: false,
        sourceSize: {
          h: 46,
          w: 48
        },
        frame: {
          h: 36,
          x: 1,
          y: 75,
          w: 36
        },
        trimmed: true,
        spriteSourceSize: {
          h: 46,
          x: 6,
          y: 5,
          w: 48
        },
        filename: 'blue_box'
      },
      {
        rotated: false,
        sourceSize: {
          h: 34,
          w: 66
        },
        frame: {
          h: 12,
          x: 59,
          y: 51,
          w: 48
        },
        trimmed: true,
        spriteSourceSize: {
          h: 34,
          x: 8,
          y: 12,
          w: 66
        },
        filename: 'purple_box'
      }
    ];
  }

  static function framesEqual(a: Frame, b: Frame): Bool {
    return a.filename == b.filename && a.rotated == b.rotated && a.sourceSize.w == b.sourceSize.w &&
        a.sourceSize.h == b.sourceSize.h && a.frame.x == b.frame.x && a.frame.y == b.frame.y &&
        a.frame.w == b.frame.w && a.frame.h == b.frame.h && a.trimmed == b.trimmed &&
        a.spriteSourceSize.x == b.spriteSourceSize.x && a.spriteSourceSize.y == b.spriteSourceSize.y &&
        a.spriteSourceSize.w == b.spriteSourceSize.w && a.spriteSourceSize.h == b.spriteSourceSize.h;
  }
}

typedef Frames = {
  var frames: Array<Frame>;
}
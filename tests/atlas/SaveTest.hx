package atlas;

import haxe.Json;
import sys.io.File;
import haxe.io.Path;
import sys.FileSystem;
import buddy.BuddySuite;

using buddy.Should;


class SaveTest extends BuddySuite {

  public function new() {
    describe('Save', {

      var config: Config;

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
      });
    });
  }
}

typedef Frames = {
  var frames: Array<Frame>;
}
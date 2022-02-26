package atlas;

import buddy.BuddySuite;

using buddy.Should;

class AtlasTest extends BuddySuite {

  public function new() {
    describe('Atlas', {
      var config: Config;

      beforeAll({
        config = {
          name: 'test',
          saveFolder: 'tests/out',
          folders: [
            'tests/testFiles'
          ],
          trimmed: true,
          extrude: 1
        }
      });

      it('Should pack an atlas.', () -> {
        final atlas = new Atlas(config);
        final success = atlas.pack();

        success.should.be(true);
        atlas.packedImage.width.should.be(132);
        atlas.packedImage.height.should.be(126);
      });

      it('Should add folder names to the file names.', () -> {
        config.folderInName = true;

        final atlas = new Atlas(config);
        final success = atlas.pack();
        
        success.should.be(true);
        for (rect in atlas.packedRects) {
          rect.name.should.startWith('testFiles_');
        }
      });
    });
  }
}
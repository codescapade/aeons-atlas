package atlas;

import buddy.BuddySuite;

using buddy.Should;

class PackerTest extends BuddySuite {

  public function new() {
    describe('Packer', {
      var config: Config;
      var atlas: Atlas;

      beforeEach({
        config = {
          name: 'test',
          saveFolder: 'tests/out',
          folders: [
            'tests/testFiles'
          ],
          extrude: 0,
          trimmed: true
        };
        atlas = new Atlas(config);
      });
      it('Should pack the rectangles in basic mode.', {
        var packer = new Packer(atlas.rects, BASIC, 4096, 4096);
        var success = packer.pack();

        success.should.be(true);
        packer.smallestBounds.width.should.be(282);
        packer.smallestBounds.height.should.be(72);
      });

      it('Should pack the rectangles in optimal mode.', () -> {
        var packer = new Packer(atlas.rects, OPTIMAL, 4096, 4096);
        var success = packer.pack();

        success.should.be(true);
        packer.smallestBounds.width.should.be(126);
        packer.smallestBounds.height.should.be(120);
      });

      it('Should pack the rectangles using a max width.', () -> {
        var packer = new Packer(atlas.rects, OPTIMAL, 100, 4096);
        var success = packer.pack();

        success.should.be(true);
        packer.smallestBounds.width.should.be(90);
        packer.smallestBounds.height.should.be(172);
      });

      it('Should pack the rectangles using a max height.', () -> {
        var packer = new Packer(atlas.rects, OPTIMAL, 4096, 100);
        var success = packer.pack();

        success.should.be(true);
        packer.smallestBounds.width.should.be(234);
        packer.smallestBounds.height.should.be(72);
      });

      it('Should not pack the rectangles if they don\'t fit', {
        var packer = new Packer(atlas.rects, OPTIMAL, 90, 90);
        var success = packer.pack();

        success.should.be(false);
      });
    });
  }
}
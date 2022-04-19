package atlas;

import haxe.io.Bytes;

import buddy.BuddySuite;

using buddy.Should;

class ImageTest extends BuddySuite {

  public function new() {
    describe('Image', {
      it('Should construct an empty image.', () -> {
        final imageWidth = 64;
        final imageHeight = 32;
        final image = new Image(imageWidth, imageHeight);
        final bytes = image.getPixels();

        image.width.should.be(imageWidth);
        image.height.should.be(imageHeight);

        // 4 bytes per pixel.
        bytes.length.should.be(imageWidth * imageHeight * 4);
        for (i in 0...bytes.length) {
          bytes.get(i).should.be(0);
        }
      });

      it('Should get and set a pixel.', () -> {
        final color = new Color(255, 100, 80, 20);
        final transparentColor = new Color(0, 0, 0, 0);
        final image = new Image(32, 32);

        final currentColor = image.getPixel(10, 10);
        currentColor.equals(transparentColor).should.be(true);

        image.setPixel(10, 10, color);
        final newColor = image.getPixel(10, 10);
        newColor.equals(color).should.be(true);
      });

      it('Should construct an image from bytes.', () -> {
        final width = 32;
        final height = 32;

        // Light orange.
        final color = new Color(255, 255, 127, 50);
        final bytes = Bytes.alloc(width * height * 4);
        var pos = 0;

        // Make every pixel orange.
        for (i in 0...(width * height)) {
          bytes.set(pos, color.a);
          bytes.set(pos + 1, color.r);
          bytes.set(pos + 2, color.g);
          bytes.set(pos + 3, color.b);
          pos += 4;
        }

        final image = new Image(width, height, bytes);
        image.width.should.be(width);
        image.height.should.be(height);
        for (y in 0...height) {
          for (x in 0...width) {
            final pixel = image.getPixel(x, y);
            pixel.equals(color).should.be(true);
          }
        }
      });

      it('Should return the pixels of an image.', {
        final width = 32;
        final height = 32;

        // Light orange.
        final color = new Color(255, 255, 127, 50);
        final bytes = Bytes.alloc(width * height * 4);
        var pos = 0;

        // Make every pixel orange.
        for (i in 0...(width * height)) {
          bytes.set(pos, color.a);
          bytes.set(pos + 1, color.r);
          bytes.set(pos + 2, color.g);
          bytes.set(pos + 3, color.b);
          pos += 4;
        }

        final image = new Image(width, height, bytes);
        image.width.should.be(width);
        image.height.should.be(height);

        final pixels = image.getPixels();

        for (i in 0...bytes.length) {
          bytes.get(i).should.be(pixels.get(i));
        }
      });

      it('Should construct an image from a file.', () -> {
        final path = 'tests/testFiles/blue_box.png';
        final image = Image.fromFile(path, false, 0);
        final darkBlue = new Color(255, 68, 132, 159);
        
        image.width.should.be(48);
        image.height.should.be(46);

        var pixel = image.getPixel(6, 5);
        pixel.equals(darkBlue).should.be(true);

        pixel = image.getPixel(41, 40);
        pixel.equals(darkBlue).should.be(true);
      });

      it('Should trim an image.', () -> {
        final path = 'tests/testFiles/purple_box.png';
        final image = Image.fromFile(path, true, 0);

        image.width.should.be(48);
        image.height.should.be(12);
        image.sourceWidth.should.be(66);
        image.sourceHeight.should.be(34);
      });
      
      it('Should extrude an image.', () -> {
        final path = 'tests/testFiles/purple_box.png';
        final image = Image.fromFile(path, true, 1);
        final darkPurple = new Color(255, 142, 68, 159);
        final normalPurple = new Color(255, 203, 97, 227);
        final transparent = new Color(0, 0, 0, 0);

        image.width.should.be(50);
        image.height.should.be(14);

        for (y in 0...image.height) {
          for (x in 0...image.width) {
            var color = image.getPixel(x, y);
            // Transparent corners when extruding 1 pixel.
            if ((x == 0 && (y == 0 || y == image.height - 1)) || (x == image.width - 1 && (y == 0 ||
                y == image.height - 1))) {
              color.equals(transparent).should.be(true);
            // Dark borders 2 pixels wide because of the extrusion.
            } else if (x == 0 || x == 1 || x == image.width - 1 || x == image.width - 2 || y == 0 || y == 1 ||
                y == image.height - 1 || y == image.height - 2) {
              color.equals(darkPurple).should.be(true);
            // The rest is the normal purple color.
            } else {
              color.equals(normalPurple).should.be(true);
            }
          }
        }
      });

      it('Should insert an image', {
        final image = new Image(40, 40);
        final color = new Color(255, 200, 100, 50);
        final transparent = new Color(0, 0, 0, 0);

        for (y in 0...image.height) {
          for (x in 0...image.width) {
            final pixel = image.getPixel(x, y);
            pixel.equals(transparent).should.be(true);
          }
        }

        final other = new Image(20, 20);
        for (y in 0...other.height) {
          for (x in 0...other.width) {
            other.setPixel(x, y, color);
          }
        }

        image.insertImage(other, 10, 15);
        for (y in 0...image.height) {
          for (x in 0...image.width) {
            final pixel = image.getPixel(x, y);
            if (x < 10 || x >= 30 || y < 15 || y >= 35) {
              pixel.equals(transparent).should.be(true);
            } else {
              pixel.equals(color).should.be(true);
            }
          }
        }
      });
    });
  }
}
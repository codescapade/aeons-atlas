package atlas;

import buddy.BuddySuite;

using buddy.Should;

class ColorTest extends BuddySuite {
  public function new() {
    describe('Color', {
      it('Should construct a color.', () -> {
        var color = new Color(20, 40, 60, 255);

        color.a.should.be(20);
        color.r.should.be(40);
        color.g.should.be(60);
        color.b.should.be(255);
      });
    });
  }
}

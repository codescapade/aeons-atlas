package atlas;

import atlas.Config;
import buddy.BuddySuite;

using buddy.Should;

class ConfigTest extends BuddySuite {
  
  public function new() {
    describe('Config', {
      it('Should set default values.', () ->  {
        var config: Config = {
          name: 'Test',
          saveFolder: 'out',
        };

        var data: ConfigData = {
          configs: [config]
        };
        setDefaultConfigValues(data);

        config.folders.length.should.be(0);
        config.files.length.should.be(0);
        config.trimmed.should.be(true);
        config.extrude.should.be(1);
        config.packMethod.should.be(PackMethod.OPTIMAL);
        config.folderInName.should.be(false);
        config.maxWidth.should.be(4096);
        config.maxHeight.should.be(4096);
        config.noData.should.be(false);
      });
    });
  }
}
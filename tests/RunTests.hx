package;

import atlas.AtlasTest;
import atlas.ColorTest;
import atlas.ConfigTest;
import atlas.ImageTest;
import atlas.PackerTest;
import atlas.SaveTest;

import buddy.Buddy;

@colorize
class RunTests implements Buddy<[AtlasTest, ColorTest, ConfigTest, ImageTest, PackerTest, SaveTest]> {}

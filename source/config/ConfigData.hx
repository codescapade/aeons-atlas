package config;

typedef ConfigData = {
  var configs: Array<Config>;
}

function setDefaultValues(data: ConfigData) {
  for (config in data.configs) {
    if (config.folders == null) {
      config.folders = [];
    }

    if (config.files == null) {
      config.files = [];
    }

    if (config.trimmed == null) {
      config.trimmed = true;
    }

    if (config.extrude == null) {
      config.extrude = 1;
    }

    if (config.packMethod == null) {
      config.packMethod = 'optimal';
    }

    if (config.folderInName == null) {
      config.folderInName = false;
    }
  }
}
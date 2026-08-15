const { getDefaultConfig } = require('expo/metro-config');
const path = require('path');

const config = getDefaultConfig(__dirname);

// Recovery's production Journey Decision lives in /runtime and is intentionally
// reused by the Expo application instead of duplicating the decision boundary.
config.watchFolders = [path.resolve(__dirname, '..')];

module.exports = config;

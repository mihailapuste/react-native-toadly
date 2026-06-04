const babelJest = require('babel-jest');

module.exports = babelJest.createTransformer({
  babelrc: false,
  configFile: false,
  presets: ['module:@react-native/babel-preset'],
});

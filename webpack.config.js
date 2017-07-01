const UglifyJSPlugin = require('uglifyjs-webpack-plugin');
var path = require('path');
var LiveReloadPlugin = require('webpack-livereload-plugin');

module.exports = {
  entry: './javascripts/script_raw.js',
  output: {
    filename: 'script.js',
    path: path.resolve(__dirname, 'public')
  },
  plugins: [
    new UglifyJSPlugin(),
    new LiveReloadPlugin()
  ]
};

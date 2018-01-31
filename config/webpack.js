/* eslint-disable quote-props, comma-dangle, import/no-extraneous-dependencies */
// This file is based on Gitlab's config/webpack.config.js file.

const path = require('path');
const webpack = require('webpack');
const CompressionPlugin = require('compression-webpack-plugin');
const StatsPlugin = require('stats-webpack-plugin');

const ROOT_PATH = path.resolve(__dirname, '..');

var config = {
  context: path.join(ROOT_PATH, 'javascripts'),

  entry: { portus: './main.js' },

  output: {
    path: path.join(ROOT_PATH, 'javascripts/dist'),
    publicPath: '/javascripts/',
    filename: '[name].min.js'
  },

  plugins: [
    new webpack.NoEmitOnErrorsPlugin(),
    new StatsPlugin('manifest.json', {
      chunkModules: false,
      source: false,
      chunks: false,
      modules: false,
      assets: true,
    }),
    new webpack.LoaderOptionsPlugin({
      minimize: true,
      debug: false,
    }),
    new webpack.optimize.UglifyJsPlugin({
      sourceMap: true,
    }),
    new webpack.DefinePlugin({
      'process.env': { NODE_ENV: JSON.stringify('production') },
    }),
    new CompressionPlugin({
      asset: '[path].gz[query]',
    }),
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery'
    })
  ],

  resolve: {
    extensions: ['.js'],
    mainFields: ['jsnext', 'main', 'browser'],
    alias: {
      '~': path.join(ROOT_PATH, 'javascripts'),
      'bootstrap/js': 'bootstrap-sass/assets/javascripts/bootstrap'
    },
  },

  devtool: 'source-map',

  module: {
    loaders: [].concat(
      {
        test: /\.js$/,
        exclude: /(node_modules|vendor\/assets)/,
        loader: 'babel-loader',
      }
    ),
  },
};

module.exports = config;

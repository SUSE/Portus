/* eslint-disable quote-props */
// This file is based on Gitlab's config/webpack.config.js file.

const path = require('path');
const webpack = require('webpack');
const CompressionPlugin = require('compression-webpack-plugin');
const StatsPlugin = require('stats-webpack-plugin');

const ROOT_PATH = path.resolve(__dirname, '..');
const IS_PRODUCTION = process.env.NODE_ENV === 'production';

var config = {
  context: path.join(ROOT_PATH, 'app/assets/javascripts'),

  entry: {
    application: './application.js',
  },

  output: {
    path: path.join(ROOT_PATH, 'public/assets/webpack'),
    publicPath: '/assets/webpack/',
    filename: IS_PRODUCTION ? '[name]-[chunkhash].js' : '[name].js',
  },

  plugins: [
    // Manifest filename must match config.webpack.manifest_filename
    // webpack-rails only needs assetsByChunkName to function properly
    new StatsPlugin('manifest.json', {
      chunkModules: false,
      source: false,
      chunks: false,
      modules: false,
      assets: true,
    }),

    // fix legacy jQuery plugins which depend on globals
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
      'window.jQuery': 'jquery',
    }),
  ],

  resolve: {
    extensions: ['.js', '.vue'],
    alias: {
      '~': path.join(ROOT_PATH, 'app/assets/javascripts'),
      'bootstrap/js': 'bootstrap-sass/assets/javascripts/bootstrap',
      'vendor': path.join(ROOT_PATH, 'vendor/assets/javascripts'),
      'vue$': 'vue/dist/vue.esm.js',
    },
  },

  devtool: 'inline-source-map',

  module: {
    loaders: [
      {
        test: /\.js$/,
        exclude: /(node_modules|vendor\/assets)/,
        loader: 'babel-loader',
        query: {
          presets: ['es2015'],
        },
      },
      {
        test: /\.vue$/,
        exclude: /(node_modules|vendor\/assets)/,
        loader: 'vue-loader',
      },
    ],
  },
};

if (IS_PRODUCTION) {
  config.devtool = 'source-map';
  config.plugins.push(
    new webpack.NoEmitOnErrorsPlugin(),
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
    }));
}

module.exports = config;

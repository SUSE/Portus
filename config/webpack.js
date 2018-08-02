/* eslint-disable quote-props, comma-dangle, import/no-extraneous-dependencies */
// This file was based on Gitlab's config/webpack.config.js file.

const path = require('path');
const webpack = require('webpack');
const CompressionPlugin = require('compression-webpack-plugin');
const StatsPlugin = require('stats-webpack-plugin');
const VueLoaderPlugin = require('vue-loader/lib/plugin');
const UglifyJSPlugin = require('uglifyjs-webpack-plugin');
const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer');

const ROOT_PATH = path.resolve(__dirname, '..');
const CACHE_PATH = path.join(ROOT_PATH, 'tmp/cache');
const IS_PRODUCTION = process.env.NODE_ENV === 'production' || process.env.NODE_ENV === 'staging';
const IS_TEST = process.env.NODE_ENV === 'test';
const { WEBPACK_REPORT } = process.env;

const VUE_VERSION = require('vue/package.json').version;
const VUE_LOADER_VERSION = require('vue-loader/package.json').version;

const devtool = IS_PRODUCTION ? 'source-map' : 'cheap-module-eval-source-map';

var config = {
  mode: IS_PRODUCTION ? 'production' : 'development',

  context: path.join(ROOT_PATH, 'app/assets/javascripts'),

  entry: {
    application: './main.js',
    unauthenticated: './unauthenticated.js',
  },

  output: {
    path: path.join(ROOT_PATH, 'public/assets/webpack'),
    publicPath: '/assets/webpack/',
    filename: IS_PRODUCTION ? '[name]-[chunkhash].js' : '[name].js',
    chunkFilename: IS_PRODUCTION ? '[name]-[chunkhash].chunk.js' : '[name].chunk.js',
  },

  resolve: {
    extensions: ['.js', '.vue'],
    mainFields: ['jsnext', 'main', 'browser'],
    alias: {
      '~': path.join(ROOT_PATH, 'app/assets/javascripts'),
      'bootstrap/js': 'bootstrap-sass/assets/javascripts/bootstrap',
      'vendor': path.join(ROOT_PATH, 'vendor/assets/javascripts'),
      'vue$': 'vue/dist/vue.esm.js',
    },
  },

  devtool,

  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: file => /node_modules|vendor[\\/]assets/.test(file) && !/\.vue\.js/.test(file),
        loader: 'babel-loader',
        options: {
          cacheDirectory: path.join(CACHE_PATH, 'babel-loader'),
        },
      },
      {
        test: /\.vue$/,
        exclude: /(node_modules|vendor\/assets)/,
        loader: 'vue-loader',
        options: {
          cacheDirectory: path.join(CACHE_PATH, 'vue-loader'),
          cacheIdentifier: [
            process.env.NODE_ENV || 'development',
            webpack.version,
            VUE_VERSION,
            VUE_LOADER_VERSION,
          ].join('|'),
        },
      },
      {
        test: /\.css$/,
        use: [
          'vue-style-loader',
          'css-loader',
        ],
      },
    ],
  },

  optimization: {
    splitChunks: {
      chunks: 'all',
      cacheGroups: {
        default: false,
        vendors: {
          priority: 10,
          test: /[\\/](node_modules|vendor[\\/]assets[\\/]javascripts)[\\/]/,
        },
      },
    },
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

    new VueLoaderPlugin(),

    // fix legacy jQuery plugins which depend on globals
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
      'window.jQuery': 'jquery',
    }),

    new webpack.IgnorePlugin(/^\.\/jquery$/, /jquery-ujs$/),

    WEBPACK_REPORT && new BundleAnalyzerPlugin({
      analyzerMode: 'static',
      generateStatsFile: true,
      openAnalyzer: false,
      reportFilename: path.join(ROOT_PATH, 'webpack-report/index.html'),
      statsFilename: path.join(ROOT_PATH, 'webpack-report/stats.json'),
    }),
  ].filter(Boolean),
};

if (IS_PRODUCTION) {
  config.optimization.minimizer = [
    new UglifyJSPlugin({
      sourceMap: true,
      cache: true,
      parallel: true,
      uglifyOptions: {
        output: {
          comments: false
        }
      }
    })
  ];

  config.plugins.push(
    new webpack.NoEmitOnErrorsPlugin(),

    new webpack.LoaderOptionsPlugin({
      minimize: true,
      debug: false,
    }),

    new webpack.DefinePlugin({
      'process.env': { NODE_ENV: JSON.stringify('production') },
    }),

    new CompressionPlugin()
  );
}

if (IS_TEST) {
  // eslint-disable-next-line
  config.externals = [require('webpack-node-externals')()];
  config.devtool = 'eval-source-map';
}

module.exports = config;

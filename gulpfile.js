// Include gulp
var gulp = require('gulp');

// Define main directories
var assets = 'assets/';
var destination = 'build/';

// Concatenate & Minify JS
var concat = require('gulp-concat');
var uglify = require('gulp-uglify');
var rename = require('gulp-rename');
var stripDebug = require('gulp-strip-debug');

gulp.task('customeScripts', function() {
  return gulp.src([assets + 'js/jquery.min.js',
                   assets + 'js/bootstrap.min.js',
                   assets + 'js/wow.js',
                   assets + 'js/portus.js',
                   assets + 'js/jquery-cookie.js',
                   assets + 'js/jquery-lang.js',
                   assets + 'js/smoothscroll.js',
                   assets + 'js/anchors.js',
                   assets + 'js/portus-language.js'
                   ])
    .pipe(concat('main.js'))
    .pipe(rename({suffix: '.min'}))
    .pipe(stripDebug())
    .pipe(uglify())
    .pipe(gulp.dest(destination + 'js'));
});

// Preprocess CSS
var less = require('gulp-less');
var path = require('path');
var minifyCss = require('gulp-minify-css');

gulp.task('less', function () {
  return gulp.src(assets +'stylesheets/portus.less')
    .pipe(less({
      paths: [ path.join(__dirname, 'less', 'includes') ]
    }))
    .pipe(rename({suffix: '.min'}))
    .pipe(minifyCss())
    .pipe(gulp.dest(destination + 'css'));
});

gulp.task('vendorCSS', ['less'], function() {
  return gulp.src([assets + 'stylesheets/animate/animate.css',
                   assets + 'stylesheets/anchors.css',
                   assets + 'stylesheets/solarized-light.css',
                   assets + 'stylesheets/fontawesome/font-awesome.min.css'])
         .pipe(concat('vendor.css'))
         .pipe(rename({suffix: '.min'}))
         .pipe(minifyCss())
         .pipe(gulp.dest(destination + 'css'))
});

// Images optimization
var imagemin = require('gulp-imagemin');
var cache = require('gulp-cache');

gulp.task('images', function() {
  return gulp.src(assets + 'images/**/*')
    .pipe(cache(imagemin({ optimizationLevel: 5, progressive: true, interlaced: true })))
    .pipe(gulp.dest(destination + 'images'));
});

// Move fontawesome to Build
gulp.task('fonts', function() {
  return gulp.src(assets + 'fonts/*')
    .pipe(gulp.dest(destination + 'fonts'));
})

// Watch for changes in our custom assets
gulp.task('watch', function() {
  // Watch .js files
  gulp.watch(assets + 'js/*.js', ['customeScripts']);
  // Watch .scss files
  gulp.watch(assets + 'stylesheets/*.less', ['less']);
  // Watch image files
  gulp.watch(assets + 'images/*', ['images']);
});


// Default Task
gulp.task('default', ['customeScripts', 'images', 'less', 'vendorCSS', 'watch', 'fonts']);

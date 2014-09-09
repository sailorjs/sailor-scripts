module.exports = function (grunt) {
	grunt.registerTask('default', [
    'compileAssets',
    'concat',
    'uglify',
    'cssmin',
    'linkAssetsBuildProd',
    'clean:build',
    'copy:build',
    'watch'
  ]);
};

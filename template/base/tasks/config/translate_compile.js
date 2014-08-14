module.exports = function(grunt) {
  grunt.config.set('translate_compile', {
    main: {
      options: {
        multipleObjects: true,
        moduleExports: true
      },
      files: {
        'config/translation.js': ['translation/*.tl']
      }
    }
  });

  grunt.loadNpmTasks('grunt-translate-compile');
};

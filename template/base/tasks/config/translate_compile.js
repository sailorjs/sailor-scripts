module.exports = function(grunt) {
  grunt.config.set('translate_compile', {
    main: {
      options: {
        translationVar  :'translations',
        asJson          : false,
        moduleExports   : true,
        coffee          : true
      },
      files: {
        'config/translation.coffee': ['translation/*.tl']
      }
    }
  });

  grunt.loadNpmTasks('grunt-translate-compile');
};

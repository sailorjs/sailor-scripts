module.exports = function(grunt) {
  grunt.config.set('js2coffee', {
    dev: {
      options: {
        single_quotes: true
      },
      src: 'config/translation.js',
      dest: 'config/translation.coffee'
    }
  });

  grunt.loadNpmTasks('grunt-js2coffee');
};

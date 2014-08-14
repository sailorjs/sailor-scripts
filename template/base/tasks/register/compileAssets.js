module.exports = function (grunt) {
	grunt.registerTask('compileAssets', [
		'translate_compile',
    'clean:dev',
		'less:dev',
		'copy:dev',
		'coffee:dev',
    'js2coffee:dev',
    'clean:translate'
	]);
};

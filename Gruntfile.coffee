matchdep = require('matchdep')
path = require('path')

module.exports = (grunt) ->
	
	grunt.registerTask('test', ['karma:unit'])
	grunt.registerTask('build', ['clean:build', 'jade:build', 'stylus:build', 'coffee:build'])
	grunt.registerTask('default', ['test', 'build']);
	
	# Load all grunt tasks (except grunt-cli) from NPM
	matchdep.filterDev('grunt-*').filter((dep) -> dep != 'grunt-cli').forEach(grunt.loadNpmTasks)    
	
	grunt.initConfig
		jade:
			build:
				files: 
					"build/index.html": ["src/index.jade"]
		karma:
			unit:
				configFile: 'karma.conf.js'
		clean:
			build: 'build'

		watch:
			files: 'src/**/*.*'
			tasks: ['build']
			options:
				interrupt: true

		coffee:
			build:
				options:
					bare: true
					join: true
				expand: true
				flatten: false
				files:
					'build/index.js': ['src/**/*.coffee']

		stylus:
			build:
				options:
					paths: [
						path.join(__dirname, 'node_modules')
					]
					import:[
						'nib'
					]
				files: 
					'build/index.css': 'src/index.styl'
					

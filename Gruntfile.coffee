matchdep = require('matchdep')
path = require('path')
bowerCdn = require('bower-cdn')

module.exports = (grunt) ->
	
	grunt.registerTask('test', ['karma:unit'])
	grunt.registerTask('build', ['clean:build', 'stylus:build', 'coffee:build', 'jade:build'])
	grunt.registerTask('default', ['test', 'build']);
	
	# Load all grunt tasks (except grunt-cli) from NPM
	matchdep.filterDev('grunt-*').filter((dep) -> dep != 'grunt-cli').forEach(grunt.loadNpmTasks)    

	cdnResolver = new bowerCdn.resolver(
		bowerShrinkWrap: 'bower-shrinkwrap.json'
		bowerPrefix: 'bower_components'
		nodeEnv: 'production'
		cdnUrl: '//bowercdn.f4tech.com:3000/'
		packageType: 'bower'
		strict: grunt.option('strict') || false;
	)
	
	grunt.initConfig
		jade:
			options:
				pretty: true
				data:					
					cdn: cdnResolver.cdn
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
					

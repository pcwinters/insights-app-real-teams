matchdep = require('matchdep')
path = require('path')
bowerCdn = require('bower-cdn')

module.exports = (grunt) ->
	
	grunt.registerTask('test', ['karma:unit'])
	grunt.registerTask('dist', ['clean:dist', 'stylus:dist', 'coffee:dist', 'jade:dist'])
	grunt.registerTask('default', ['test', 'dist']);
	
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
			dist:
				files: 
					"dist/index.html": ["src/index.jade"]
		karma:
			unit:
				configFile: 'karma.conf.js'
		clean:
			dist: 'dist'

		watch:
			files: 'src/**/*.*'
			tasks: ['dist']
			options:
				interrupt: true

		coffee:
			dist:
				options:
					bare: true
					join: true
				expand: true
				flatten: false
				files:
					'dist/index.js': ['src/**/*.coffee']

		stylus:
			dist:
				options:
					paths: [
						path.join(__dirname, 'node_modules')
					]
					import:[
						'nib'
					]
				files: 
					'dist/index.css': 'src/index.styl'
					

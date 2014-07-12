var bower_components = [
	'https://rally1.rallydev.com/apps/2.0rc3/sdk-debug.js',
	'bower_components/angular/angular.js',
	'bower_components/angular-mocks/angular-mocks.js'	
]

module.exports = function(config) {
	config.set({
		
		frameworks: ['jasmine'],

		// list of files / patterns to load in the browser
		files: bower_components.concat([			
			'src/**/*.coffee',
			'test/**/*.coffee'
		]),

		preprocessors: {
			'**/*.coffee': ['coffee']
		},

		coffeePreprocessor: {
			// options passed to the coffee compiler
			options: {
				bare: true,
				sourceMap: false
			},
			// transforming the filenames
			transformPath: function(path) {
				return path.replace(/\.coffee$/, '.js');
			}
		},

		// list of files to exclude
		exclude: [],

		// test results reporter to use
		// possible values: 'dots', 'progress', 'junit'
		reporters: ['progress'],

		// web server port
		port: 9876,

		// cli runner port
		runnerPort: 9100,

		// enable / disable colors in the output (reporters and logs)
		colors: true,

		// enable / disable watching file and executing tests whenever any file changes
		autoWatch: false,


		// Start these browsers, currently available:
		// - Chrome
		// - ChromeCanary
		// - Firefox
		// - Opera
		// - Safari (only Mac)
		// - PhantomJS
		// - IE (only Windows)
		browsers: ['PhantomJS'],

		// If browser does not capture in given timeout [ms], kill it
		captureTimeout: 60000,

		// Continuous Integration mode
		// if true, it capture browsers, run tests and exit
		singleRun: true
	});
};

module.exports.bower_components = bower_components;

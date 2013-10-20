module.exports = (config) ->
  config.set
    basePath: ''

    frameworks: ['cucumber-console']
    files: [
      "components/jquery/jquery.min.js"
      { pattern: 'spec/**/*.feature', included: false, served: true, watch: true }
      { pattern: 'spec/**/*.js', included: false, watch: true }
    ]

    exclude: []
    reporters: ['progress']
    port: 9876
    colors: true
    autoWatch: true
    browsers: ['PhantomJS']
    singleRun: false
    logLevel: 'INFO'


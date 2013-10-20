module.exports = (grunt) ->

  "use strict"

  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    banner: '/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %> - ' +
          '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
          '<%= pkg.homepage ? "* " + pkg.homepage + "\\n" : "" %>' +
          '* Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>;' +
          ' Licensed <%= _.pluck(pkg.licenses, "type").join(", ") %> */\n'

    coffeelint:
      product: ["src/**/*.coffee"]
      options:
        max_line_length:
          value: 120
          level: "warn"

    coffee:
      product:
        options:
          bare: true
        expand: true
        cwd: 'src/'
        src: './**/*.coffee'
        dest: './'
        ext: '.js'

    env:
      dev:
        PHANTOMJS_BIN: __dirname + '/node_modules/karma-phantomjs-launcher/node_modules/phantomjs/bin/phantomjs'
    
    karma:
      options:
        configFile: 'karma.conf.coffee'
        browsers: ['PhantomJS']
        reporters: ['progress']
        logLevel: 'INFO'
        singleRun: false
      unit:
        autoWatch: false
        background: true
      continuous:
        autoWatch: false
        singleRun: true

    watch:
      product:
        files: ["src/**/*.coffee"]
        tasks: ['build', 'karma:unit:run']
      feature:
        files: ["spec/**/*.feature"]
        tasks: ['karma:unit:run']

  grunt.loadNpmTasks "grunt-env"
  grunt.loadNpmTasks "grunt-karma"
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.registerTask "default", ['env:dev', 'karma:unit', 'watch']
  grunt.registerTask "build", ['coffee:product', 'coffeelint']
  grunt.registerTask "test", ['env:dev', 'karma:continuous']

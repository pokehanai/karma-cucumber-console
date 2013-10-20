createPattern = (path) ->
  pattern: path, included: true, served: true, watched: false

initCucumber = (files) ->
  files.unshift createPattern "#{__dirname}/adapter.js"
  files.unshift createPattern "#{__dirname}/cucumber-js-runner.js"
  files.unshift createPattern "#{__dirname}/../vendor/cucumber.js"

initCucumber.$inject = ['config.files']

module.exports =
  'framework:cucumber-console': ['factory', initCucumber]

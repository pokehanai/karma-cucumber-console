# Wrapper around cucumber-js to create a standard runner & reporter
# for client side testing of multiple features / step definitions
# Initially the runner has the following reporters available: cucumber-html-reporter and
# karma-cucumber for use with karma (http://karma-runner.github.com/)
# Requires: async and jQuery
"use strict"

((global) ->
  my = {}
  reporters = []
  featureUrls = []
  features = null
  stepDefinitions = []

  # Load the features for the runner.
  # Returns `deferred` object, which will be resolved when it all of
  # features loading process have done(either succeeded or not).
  loadFeatures = () ->
    features = featureUrls.map (url) ->
      url: url, text: null

    loadFeature = (url) ->
      $.get(url)
      .done (text) ->
        # find and set the text on the corresponding feature
        features.forEach (feature) ->
          if feature.url is url
            feature.text = text
            return false # exit loop

        # run cucumber after all features are loaded
      .fail (err) ->
        throw err if err

    # Load all features then resolve `deferred` object.
    deferred = $.Deferred()
    deferreds = featureUrls.map (url) ->
      loadFeature url
    $.when.apply($, deferreds).always ->
      deferred.resolve()
    deferred

  # Load the .feature definitions to test
  # @param {Array.<String>} urls
  global.addFeatures = (urls) ->
    featureUrls = featureUrls.concat urls

  # Add step definition functions for the features
  # @param {Function} func
  global.addStepDefinitions = (func) ->
    stepDefinitions.push func

  # Attach a reporter to the cucumber test runner
  # @param reporter

  Cucumber.attachReporter = (reporter) ->
    reporters.push reporter

   # Return the feature urls to run
   # @returns {Array}
  Cucumber.featureUrls = ->
    featureUrls

    # forces a reload of features every time
  features = null
  
   # Run the cucumber feature tests
   # @param callback Called when complete
  Cucumber.run = (callback) ->
    loadFeatures()
    .always ->
      return my if features.length is 0

      stepDefinitionsSource = ->
        step @ for step in stepDefinitions
    
      runCucumber = (feature) ->
        deferred = $.Deferred()
        cucumber = Cucumber feature.text, stepDefinitionsSource
        reporters.forEach (reporter) ->
          listener = reporter.getListener feature
          cucumber.attachListener listener
        cucumber.start ->
          deferred.resolve()
        deferred

      runLoop = ->
        feature = features.shift()
        runCucumber(feature)
        .done ->
          if features.length
            runLoop()
          else
            callback()

      runLoop()
      return my

)(window)

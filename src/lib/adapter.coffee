((global) ->
  # Karma listener
  class KarmaListener
    scenarioSuccess: true
    scenarioSkipped: false
    scenarioLog: []

    currentFeature: null
    currentScenario: null
    currentStep: null

    constructor: (@karma) ->

    hear: (event, callback) ->
      eventName = 'on' + event.getName()
      @[eventName]? event
      callback()
    
    onBeforeFeature: (event) ->
      @currentFeature = event.getPayloadItem 'feature'

    onBeforeScenario: (event) ->
      @currentScenario = event.getPayloadItem 'scenario'
      @currentScenario._time = new Date().getTime()

    onBeforeStep: (event) ->
      @currentStep = event.getPayloadItem 'step'

    onStepResult: (event) ->
      stepResult = event.getPayloadItem 'stepResult'

      if @scenarioSuccess
        @scenarioSuccess = stepResult.isSuccessful()
      if @scenarioSkipped
        @scenarioSkipped = stepResult.isPending() or stepResult.isUndefined() or stepResult.isSkipped()

      error = stepResult.getFailureException?()
      if error
        if error.stack
          errorMessage = "#{@currentStep.getName()}\n#{error.stack}"
        else
          errorMessage = "@currentStep.getName()\nFAILED: #{error}"
        @scenarioLog.push errorMessage

    onAfterScenario: (event) ->
      scenarioName = @currentScenario.getName()
      featureName = @currentFeature.getName()
      time = if @scenarioSkipped then 0 else new Date().getTime() - @currentScenario._time

      result =
        description: scenarioName
        log: @scenarioLog
        suite: [featureName]
        success: @scenarioSuccess
        skipped: @scenarioSkipped
        time: time
        total: 1

      @karma.result result

  # Very simple reporter for cucumber
  class KarmaReporter
    constructor: (@karma) ->

    # returns the listener to report on a feature
    getListener: (feature) ->
      new KarmaListener @karma

  isAngularMockDumpAvailable = ->
    dumpFunc = global?.angular?.mock?.dump
    typeof dumpFunc is 'function'

  getValueForDumper = (value) ->
    if isAngularMockDumpAvailable()
      global.angular.mock.dump value
    else
      value

  loadFeatures = (karma) ->
    global.addFeatures collectFileUrls karma, (url) -> /\.feature$/.test url

  loadStepDifinitions = (karma, callback) ->
    stepDifinitionUrls = collectFileUrls karma, (url) -> /[-_]steps\.js$/.test url
    return callback() if stepDifinitionUrls.length is 0
    for url in stepDifinitionUrls
      p = $.get url
      p.always ->
        stepDifinitionUrls.shift()
        callback() if stepDifinitionUrls.length is 0
    
  collectFileUrls = (karma, pred) ->
    (file for file of karma.files).filter pred

  createStartFn = (karma) ->
    (config) ->
      loadFeatures karma
      loadStepDifinitions karma, ->
        Cucumber.attachReporter new KarmaReporter karma
        Cucumber.run ->
          karma.complete {}

  createDumpFn = (karma, serialize) ->
    (args...) ->
      if serialize
        args = serialize arg for arg in args
      karma.info dump: args

  global.__karma__.start = createStartFn window.__karma__
  global.dump = createDumpFn window.__karma__, getValueForDumper

)(window)

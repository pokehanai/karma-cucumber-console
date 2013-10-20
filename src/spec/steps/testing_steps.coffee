addStepDefinitions (scenario) ->
  # Provide a custom World constructor. It's optional, a default one is supplied.
  scenario.World = (callback) ->
    callback()

  # Define your World, here is where you can add some custom utlity functions you
  # want to use with your Cucumber step definitions, this is usually moved out
  # to its own file that you include in your Karma config
  proto = scenario.World.prototype
  proto.appSpecificUtilityFunction = () ->
    # do some common stuff with your app

  scenario.Before (callback) ->
    # Use a custom utility function
    this.appSpecificUtilityFunction()

    callback()

  scenario.Given /^set the value to (\d+)$/, (value, callback) ->
    @value = parseInt value
    callback()

  scenario.When /^add (\d+) to the value$/, (value, callback) ->
    @value? and @value += parseInt value
    callback()
  
  scenario.Then /^the value is (\d+)$/, (value, callback) ->
    if @value? and @value is parseInt value
      callback()
    else
      callback.fail "the value is not #{value} but #{@value}"

  scenario.After (callback) ->
    callback()


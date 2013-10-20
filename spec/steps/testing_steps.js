addStepDefinitions(function(scenario) {
  var proto;
  scenario.World = function(callback) {
    return callback();
  };
  proto = scenario.World.prototype;
  proto.appSpecificUtilityFunction = function() {};
  scenario.Before(function(callback) {
    this.appSpecificUtilityFunction();
    return callback();
  });
  scenario.Given(/^set the value to (\d+)$/, function(value, callback) {
    this.value = parseInt(value);
    return callback();
  });
  scenario.When(/^add (\d+) to the value$/, function(value, callback) {
    (this.value != null) && (this.value += parseInt(value));
    return callback();
  });
  scenario.Then(/^the value is (\d+)$/, function(value, callback) {
    if ((this.value != null) && this.value === parseInt(value)) {
      return callback();
    } else {
      return callback.fail("the value is not " + value + " but " + this.value);
    }
  });
  return scenario.After(function(callback) {
    return callback();
  });
});

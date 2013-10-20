"use strict";
(function(global) {
  var featureUrls, features, loadFeatures, my, reporters, stepDefinitions;
  my = {};
  reporters = [];
  featureUrls = [];
  features = null;
  stepDefinitions = [];
  loadFeatures = function() {
    var deferred, deferreds, loadFeature;
    features = featureUrls.map(function(url) {
      return {
        url: url,
        text: null
      };
    });
    loadFeature = function(url) {
      return $.get(url).done(function(text) {
        return features.forEach(function(feature) {
          if (feature.url === url) {
            feature.text = text;
            return false;
          }
        });
      }).fail(function(err) {
        if (err) {
          throw err;
        }
      });
    };
    deferred = $.Deferred();
    deferreds = featureUrls.map(function(url) {
      return loadFeature(url);
    });
    $.when.apply($, deferreds).always(function() {
      return deferred.resolve();
    });
    return deferred;
  };
  global.addFeatures = function(urls) {
    return featureUrls = featureUrls.concat(urls);
  };
  global.addStepDefinitions = function(func) {
    return stepDefinitions.push(func);
  };
  Cucumber.attachReporter = function(reporter) {
    return reporters.push(reporter);
  };
  Cucumber.featureUrls = function() {
    return featureUrls;
  };
  features = null;
  return Cucumber.run = function(callback) {
    return loadFeatures().always(function() {
      var runCucumber, runLoop, stepDefinitionsSource;
      if (features.length === 0) {
        return my;
      }
      stepDefinitionsSource = function() {
        var step, _i, _len, _results;
        _results = [];
        for (_i = 0, _len = stepDefinitions.length; _i < _len; _i++) {
          step = stepDefinitions[_i];
          _results.push(step(this));
        }
        return _results;
      };
      runCucumber = function(feature) {
        var cucumber, deferred;
        deferred = $.Deferred();
        cucumber = Cucumber(feature.text, stepDefinitionsSource);
        reporters.forEach(function(reporter) {
          var listener;
          listener = reporter.getListener(feature);
          return cucumber.attachListener(listener);
        });
        cucumber.start(function() {
          return deferred.resolve();
        });
        return deferred;
      };
      runLoop = function() {
        var feature;
        feature = features.shift();
        return runCucumber(feature).done(function() {
          if (features.length) {
            return runLoop();
          } else {
            return callback();
          }
        });
      };
      runLoop();
      return my;
    });
  };
})(window);

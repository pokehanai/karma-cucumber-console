var __slice = [].slice;

(function(global) {
  var KarmaListener, KarmaReporter, collectFileUrls, createDumpFn, createStartFn, getValueForDumper, isAngularMockDumpAvailable, loadFeatures, loadStepDifinitions;
  KarmaListener = (function() {
    KarmaListener.prototype.scenarioSuccess = true;

    KarmaListener.prototype.scenarioSkipped = false;

    KarmaListener.prototype.scenarioLog = [];

    KarmaListener.prototype.currentFeature = null;

    KarmaListener.prototype.currentScenario = null;

    KarmaListener.prototype.currentStep = null;

    function KarmaListener(karma) {
      this.karma = karma;
    }

    KarmaListener.prototype.hear = function(event, callback) {
      var eventName;
      eventName = 'on' + event.getName();
      if (typeof this[eventName] === "function") {
        this[eventName](event);
      }
      return callback();
    };

    KarmaListener.prototype.onBeforeFeature = function(event) {
      return this.currentFeature = event.getPayloadItem('feature');
    };

    KarmaListener.prototype.onBeforeScenario = function(event) {
      this.currentScenario = event.getPayloadItem('scenario');
      return this.currentScenario._time = new Date().getTime();
    };

    KarmaListener.prototype.onBeforeStep = function(event) {
      return this.currentStep = event.getPayloadItem('step');
    };

    KarmaListener.prototype.onStepResult = function(event) {
      var error, errorMessage, stepResult;
      stepResult = event.getPayloadItem('stepResult');
      if (this.scenarioSuccess) {
        this.scenarioSuccess = stepResult.isSuccessful();
      }
      if (this.scenarioSkipped) {
        this.scenarioSkipped = stepResult.isPending() || stepResult.isUndefined() || stepResult.isSkipped();
      }
      error = typeof stepResult.getFailureException === "function" ? stepResult.getFailureException() : void 0;
      if (error) {
        if (error.stack) {
          errorMessage = "" + (this.currentStep.getName()) + "\n" + error.stack;
        } else {
          errorMessage = "@currentStep.getName()\nFAILED: " + error;
        }
        return this.scenarioLog.push(errorMessage);
      }
    };

    KarmaListener.prototype.onAfterScenario = function(event) {
      var featureName, result, scenarioName, time;
      scenarioName = this.currentScenario.getName();
      featureName = this.currentFeature.getName();
      time = this.scenarioSkipped ? 0 : new Date().getTime() - this.currentScenario._time;
      result = {
        description: scenarioName,
        log: this.scenarioLog,
        suite: [featureName],
        success: this.scenarioSuccess,
        skipped: this.scenarioSkipped,
        time: time,
        total: 1
      };
      return this.karma.result(result);
    };

    return KarmaListener;

  })();
  KarmaReporter = (function() {
    function KarmaReporter(karma) {
      this.karma = karma;
    }

    KarmaReporter.prototype.getListener = function(feature) {
      return new KarmaListener(this.karma);
    };

    return KarmaReporter;

  })();
  isAngularMockDumpAvailable = function() {
    var dumpFunc, _ref, _ref1;
    dumpFunc = global != null ? (_ref = global.angular) != null ? (_ref1 = _ref.mock) != null ? _ref1.dump : void 0 : void 0 : void 0;
    return typeof dumpFunc === 'function';
  };
  getValueForDumper = function(value) {
    if (isAngularMockDumpAvailable()) {
      return global.angular.mock.dump(value);
    } else {
      return value;
    }
  };
  loadFeatures = function(karma) {
    return global.addFeatures(collectFileUrls(karma, function(url) {
      return /\.feature$/.test(url);
    }));
  };
  loadStepDifinitions = function(karma, callback) {
    var p, stepDifinitionUrls, url, _i, _len, _results;
    stepDifinitionUrls = collectFileUrls(karma, function(url) {
      return /[-_]steps\.js$/.test(url);
    });
    if (stepDifinitionUrls.length === 0) {
      return callback();
    }
    _results = [];
    for (_i = 0, _len = stepDifinitionUrls.length; _i < _len; _i++) {
      url = stepDifinitionUrls[_i];
      p = $.get(url);
      _results.push(p.always(function() {
        stepDifinitionUrls.shift();
        if (stepDifinitionUrls.length === 0) {
          return callback();
        }
      }));
    }
    return _results;
  };
  collectFileUrls = function(karma, pred) {
    var file;
    return ((function() {
      var _results;
      _results = [];
      for (file in karma.files) {
        _results.push(file);
      }
      return _results;
    })()).filter(pred);
  };
  createStartFn = function(karma) {
    return function(config) {
      loadFeatures(karma);
      return loadStepDifinitions(karma, function() {
        Cucumber.attachReporter(new KarmaReporter(karma));
        return Cucumber.run(function() {
          return karma.complete({});
        });
      });
    };
  };
  createDumpFn = function(karma, serialize) {
    return function() {
      var arg, args, _i, _len;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (serialize) {
        for (_i = 0, _len = args.length; _i < _len; _i++) {
          arg = args[_i];
          args = serialize(arg);
        }
      }
      return karma.info({
        dump: args
      });
    };
  };
  global.__karma__.start = createStartFn(window.__karma__);
  return global.dump = createDumpFn(window.__karma__, getValueForDumper);
})(window);

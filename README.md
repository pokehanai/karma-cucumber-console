karma-cucumber-console
======================

> [CucumberJS][] for [Karma][] (Temporal)

[CucumberJS]: https://github.com/cucumber/cucumber-js
[karma]:    http://karma-runner.github.io

Dependency
----------

[jQuery](http://jquery.com/).

Installation
------------

Install the module from npm:

```sh
$ npm install https://github.com/pokehanai/karma-cucumber-console/archive/v0.0.1.tar.gz
```

Add `es5-shim` to the `frameworks` key after `requirejs` in your Karma configuration:

```js
module.exports = function(karma) {
  karma.set({
    // frameworks to use
    frameworks: [],
	files: [
	  "path/to/jquery"
	  ...
	],
    // ...
  });
};
```

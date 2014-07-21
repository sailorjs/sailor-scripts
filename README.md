# Sailor Scripts

> Scripts for Running Sailor [![Build Status](https://secure.travis-ci.org/sailorjs/sailor-scripts.png?branch=master)](https://travis-ci.org/sailorjs/sailor-scripts)

## Install

```
npm install sailor-scripts
```

## Usage

```
var scripts = require('sailor-scripts)
```

All command use a optional `callback` and optional `object`.

Check the structure of `sails.config` in [example/sails.config.js](example/sails.config.js).

## API

#### .clean()

Delete `testApp`

#### .build([callback])

Create a `testApp` folder. By default, if `testApp` exist first delete it and later generate a new proyect.

#### .lift([options], [callback])

Running a Sails server from `testApp` folder.

#### .buildAndLift([options], [callback])

Concatenate `build` and `lift` options.

## License

MIT © [Kiko Beats](http://kikobeats.com)



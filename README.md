# Sailor Scripts

[![Build Status](http://img.shields.io/travis/sailorjs/sailor-translate/master.svg?style=flat)](https://travis-ci.org/sailorjs/sailor-scripts)
[![Dependency status](http://img.shields.io/david/sailorjs/sailor-translate.svg?style=flat)](https://david-dm.org/sailorjs/sailor-scripts)
[![Dev Dependencies Status](http://img.shields.io/david/dev/sailorjs/sailor-translate.svg?style=flat)](https://david-dm.org/sailorjs/sailor-scripts#info=devDependencies)
[![NPM Status](http://img.shields.io/npm/dm/sailor-translate.svg?style=flat)](https://www.npmjs.org/package/sailor-scripts)
[![Gittip](http://img.shields.io/gittip/Kikobeats.svg?style=flat)](https://www.gittip.com/Kikobeats/)

> Scripts for Running Sailor

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

#### .lift([path], [options], [callback])

Running a Sails server from `testApp` folder.

#### .buildAndLift([options], [callback])

Concatenate `build` and `lift` options.

## License

MIT © [Kiko Beats](http://kikobeats.com)



# Sailor Scripts

[![Build Status](http://img.shields.io/travis/sailorjs/sailor-scripts/master.svg?style=flat)](https://travis-ci.org/sailorjs/sailor-scripts)
[![Dependency status](http://img.shields.io/david/sailorjs/sailor-scripts.svg?style=flat)](https://david-dm.org/sailorjs/sailor-scripts)
[![Dev Dependencies Status](http://img.shields.io/david/dev/sailorjs/sailor-scripts.svg?style=flat)](https://david-dm.org/sailorjs/sailor-scripts#info=devDependencies)
[![NPM Status](http://img.shields.io/npm/dm/sailor-scripts.svg?style=flat)](https://www.npmjs.org/package/sailor-scripts)
[![Gittip](http://img.shields.io/gittip/Kikobeats.svg?style=flat)](https://www.gittip.com/Kikobeats/)

> Scripts for Running Sailor

## Install

```
npm install sailor-scripts
```

## Usage

```
scripts = require 'sailor-scripts'
```

## API

#### .run(\<command>, [callback])

Run a shell command without returning the output

#### .exec(\<command>, [callback])

Exec a shell command and return the output or return a callback with the output.

#### .newBase([directory], [options], [callback])

Generate a new Sailor Base Proyect.

* `dir` by default is `process.cwd()`
* `options` can be:
	* `name`: name of the folder project
	* `organization`: name of the organization (for git repository)
	* `repository`: name of the git reposository

By default the `name` and the `repository` is the same (`testApp`) and the organization is `sailorjs`


#### .newModule([directory], [options], [callback])

Generate a new Module for Sailor Base Proyect.

* `dir` by default is `process.cwd()`
* `options` can be:
	* `name`: name of the folder project
	* `organization`: name of the organization (for git repository)
	* `repository`: name of the git reposository

By default the `name` and the `repository` is the same (`testApp`) and the organization is `sailorjs`


#### .link(\<origin>, \<destination>, [callback])

Create a symbolic link. User for linked a module with your base.

#### .writePluginFile(\<origin>, [baseName], [callback])

Use for write in the `config/plugins` the name of your module. Necessary for load the plugin in the Sails core.

#### .clean(\<directory>, [callback])

Clear a directory.

#### .lift([directory], [options], [callback])

Lift a project, like:

* `directory`: path under start the server. by default is `procress.cwd()`
* `options`: options to pass to sails core (like log level, node environment,...)



## License

MIT © [Kiko Beats](http://kikobeats.com)



# Backbone environment for node.js (capt)

`capt` is a tool to help you quickly create backbone.js applications and maintain a good directory structure and give you build tools to help development.

This version of `capt` only includes the `new` and `generate` tasks.

It assumes the project will use [RequireJS](http://requirejs.org/) for module loading and dependency management. JavaScript is the preferred language in this fork.


Directory Structure:

    index.html
    app/
     app.js
     collections/
     models/
     routers/
      templates/
     views/
    css/
    lib/
    spec/

Testing framework:

* Jasmine

Libraries built in (as AMD modules):

* jQuery
* backbone.js
* underscore.js
* require.js
* handlebars.js
* require-handlebars-plugin (https://github.com/SlexAxton/require-handlebars-plugin)

## Getting Started
Create a new project by
 
    capt new projectname

Open `projectname/index.html` to see your initial app

Then you can `cd` into the directory `projectname` to start using generators

    cd projectname

Generate a model
 
    capt generate model animal
    
Generate a collection with the model name

    capt generate collection animal

Or generate some views with the directory name and view name

    capt generate view animals show



## License

[BSD Licensed](http://creativecommons.org/licenses/BSD/). YUI Compressor and Closure are licensed under their respective licences.

## Author

Ben Nolan @bnolan bnolan@gmail.com

Modified by Burin Asavesna @burin

# Changelog

0.5.4 - Fixed template which said `initailizer` instead of `initialize`
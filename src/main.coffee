fs = require('fs')
sys = require('sys')
Path = require("path")

root = __dirname + "/../"
router = require("#{root}/lib/router")
request = require("#{root}/lib/request")
_ = require("#{root}/lib/underscore")
server = router.getServer()
Project = require("#{root}/src/project").Project

String.prototype.capitalize = ->
  this.charAt(0).toUpperCase() + this.substring(1).toLowerCase()

OptionParser = require("#{root}/lib/parseopt").OptionParser
parser = new OptionParser {
  minargs : 0
  maxargs : 10
}

$usage = '''
Usage:
  
  capt new projectname 
    - create a new project

  Code generators:
    * capt generate model post
    * capt generate router posts
    * capt generate view posts show
    
    
'''

# Parse command line
data = parser.parse()

#
# Raise an error
#
raise = (error) ->
  sys.puts error
  process.exit()

task = (command, description, func) ->
  length = command.split(' ').length
  
  if data.arguments.slice(0,length).join(" ") == command
    func(data.arguments.slice(length))
    task.done = true
    

task 'new', 'create a new project', (arguments) ->
  project = arguments[0] or raise("Must supply a name for new project.")

  sys.puts " * Creating folders"

  dirs = ["", "spec", "spec/jasmine", "spec/models", "spec/collections", "spec/routers", "spec/views", "spec/fixtures",
         "app", "app/views", "app/templates", "app/templates/helpers", "app/templates/i18n","app/collections", "app/models", "app/routers",
         "lib", "lib/Handlebars", "css"]

  for dir in dirs
    fs.mkdirSync "#{project}/#{dir}", 0755

  sys.puts " * Creating directory structure"

  libs = {
    "lib/require-jquery.js" : "lib/require-jquery.js"
    "lib/underscore.js" : "lib/underscore.js"
    "lib/backbone.js" : "lib/backbone.js"
    "lib/handlebars.js" : "lib/handlebars.js"
    "lib/hbs.js" : "lib/hbs.js"
    "lib/Handlebars/i18nprecompile.js" : "lib/Handlebars/i18nprecompile.js"
    "index.html" : "html/index.html"
    "css/bootstrap.css" : "css/bootstrap.css"
    "app/app.js" : "app.js"
    "app/routers/ApplicationRouter.js" : "routers/ApplicationRouter.js"
    "app/views/ApplicationView.js" : "views/ApplicationView.js"
    "app/templates/helpers/all.js" : "templates/helpers/all.js"
    "app/templates/i18n/en_us.json" : "templates/i18n/en_us.json"
    "app/templates/i18n/en_ca.json" : "templates/i18n/en_ca.json"
    "spec/index.jst" : "html/runner.jst"
    "spec/jasmine/jasmine-html.js" : "lib/jasmine-html.js"
    "spec/jasmine/jasmine.css" : "lib/jasmine.css"
    "spec/jasmine/jasmine.js" : "lib/jasmine.js"
  }
  
  downloadLibrary = (path, lib) ->
    request { uri : lib }, (error, response, body) ->
      if (!error && response.statusCode == 200)
        sys.puts "   * " + Path.basename(path)
        fs.writeFileSync("#{project}/#{path}", body)
      else
        sys.puts "   * [ERROR] Could not download " + Path.basename(path)

  copyLibrary = (path, lib) ->
    fs.writeFileSync(Path.join(project, path), fs.readFileSync(lib) + "")
  
  for path, lib of libs
    if lib.match(/^http/)
      downloadLibrary(path, lib)
    else
      copyLibrary(path, Path.join(root, "templates/", lib))
    
task 'generate model', 'create a new model', (arguments) ->
  project = new Project(process.cwd())

  if arguments[0]
    model = arguments[0].toLowerCase()
  else
    raise("Must supply a name for the model")

  copyFile = (from, to) ->
    ejs = fs.readFileSync(from) + ""
    fs.writeFileSync(Path.join(project.root, to), _.template(ejs, { project : project, model : model }))
    sys.puts " * Created #{to}"

  copyFile "#{root}/templates/models/model.#{project.language()}", "app/models/#{model.capitalize()}.#{project.language()}"
  copyFile "#{root}/templates/models/spec.#{project.language()}", "spec/models/#{model.capitalize()}.#{project.language()}"


task 'generate collection', 'create a new collection', (arguments) ->
  project = new Project(process.cwd())

  if arguments[0]
    model = arguments[0].toLowerCase()
  else
    raise("Must supply a name for the model")

  copyFile = (from, to) ->
    ejs = fs.readFileSync(from) + ""
    fs.writeFileSync(Path.join(project.root, to), _.template(ejs, { project : project, model : model }))
    sys.puts " * Created #{to}"

  copyFile "#{root}/templates/collection/collection.#{project.language()}", "app/collections/#{model.capitalize()}Collection.#{project.language()}"
  copyFile "#{root}/templates/collection/spec.#{project.language()}", "spec/collections/#{model.capitalize()}Collection.#{project.language()}"


task 'generate router', 'create a new router', (arguments) ->
  project = new Project(process.cwd())

  if arguments[0]
    router = arguments[0].toLowerCase()
  else
    raise("Must supply a name for the router")

  copyFile = (from, to) ->
    ejs = fs.readFileSync(from) + ""
    fs.writeFileSync(Path.join(project.root, to), _.template(ejs, { project : project, router : router }))
    sys.puts " * Created #{to}"

  try
    fs.mkdirSync "#{project.root}/app/views/#{router}", 0755
    fs.mkdirSync "#{project.root}/app/templates/#{router}", 0755
  catch e
    # ...
    
  copyFile "#{root}/templates/routers/router.#{project.language()}", "app/router/#{router.capitalize()}Router.#{project.language()}"
  copyFile "#{root}/templates/routers/spec.#{project.language()}", "spec/routers/#{router.capitalize}Router.#{project.language()}"

task 'generate view', 'create a new view', (arguments) ->
  project = new Project(process.cwd())

  if arguments[0] and arguments[1]
    router = arguments[0].toLowerCase()
    view = arguments[1].toLowerCase()
  else
    raise("Must supply a name for the router and then view")

  copyFile = (from, to) ->
    ejs = fs.readFileSync(from).toString()
    fs.writeFileSync(Path.join(project.root, to), _.template(ejs, { project : project, router: router, view : view }))
    sys.puts " * Created #{to}"

  if !Path.existsSync("#{project.root}/app/views/#{router}")
    fs.mkdirSync "#{project.root}/app/views/#{router}", 0755

  if !Path.existsSync("#{project.root}/spec/views/#{router}")
    fs.mkdirSync "#{project.root}/spec/views/#{router}", 0755


  if !Path.existsSync("#{project.root}/app/templates/#{router}")
    fs.mkdirSync "#{project.root}/app/templates/#{router}", 0755

  copyFile "#{root}/templates/views/view.#{project.language()}", "app/views/#{router}/#{view.capitalize()}View.#{project.language()}"
  copyFile "#{root}/templates/templates/template.hbs", "app/templates/#{router}/#{view.capitalize()}Template.hbs"
  copyFile "#{root}/templates/views/spec.#{project.language()}", "spec/views/#{router}/#{view.capitalize()}View.#{project.language()}"


if !task.done
  sys.puts $usage
  process.exit()

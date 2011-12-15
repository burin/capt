fs = require('fs')
sys = require('sys')
Path = require("path")
Glob = require("glob").globSync

root = __dirname + "/../"
router = require("#{root}/lib/router")
request = require("#{root}/lib/request")
_ = require("#{root}/lib/underscore")
yaml = require("#{root}/lib/yaml")
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
    
  capt server
    - serve the current project on port 3000
      
  capt watch
    - watch the current project and recompile as needed

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
    
#
# Start the server
#  
task 'server', 'start a webserver', (arguments) ->
  project = new Project(process.cwd())

  server.get "/", (req, res, match) ->
    ejs = fs.readFileSync("#{project.root}/index.jst") + ""
    _.template(ejs, { project : project })

  server.get "/spec/", (req, res) ->
    ejs = fs.readFileSync("#{project.root}/spec/index.jst") + ""
    _.template(ejs, { project : project })

  server.get /(.*)/, router.staticDirHandler(project.root, '/')

  project.watchAndBuild()
  server.listen(3000)

task 'build', 'concatenate and minify all javascript and stylesheets for production', (arguments) ->
  project = new Project(process.cwd())

  sys.puts "Building #{project.name()}..."

  try
    fs.mkdirSync "#{project.root}/build", 0755
  catch e
    # .. ok ..

  output = "#{project.root}/build"
  
  try
    fs.mkdirSync output, 0755
  catch e
    # .. ok ..

  sys.puts " * Building css and js componenets"

  # Todo - emit an event from project when the build is complete
  project.watchAndBuild()

  setTimeout( =>
    sys.puts " * #{output}/bundled-javascript.js"
    project.bundleJavascript("#{output}/bundled-javascript.js")

    # Recompile the index.html to use the bundled urls
    sys.puts " * #{output}/index.html"

    project.scriptIncludes = ->
      project.getScriptTagFor('/bundled-javascript.js')

    project.stylesheetIncludes = ->
      project.getStyleTagFor('/bundled-stylesheet.css')

    for file in project.getDependencies('static')
      project.compileFile(file)
    # ejs = fs.readFileSync("#{project.root}/index.jst") + ""
    # fs.writeFileSync("#{output}/index.html", _.template(ejs, { project : project }))

  , 2000)
  
  # sys.puts " * #{output}/bundled-stylesheet.css"
  # sys.puts "   - " + project.getStylesheetDependencies().join("\n   - ")
  # 
  # project.bundleStylesheet("#{output}/bundled-stylesheet.css")
  # 


task 'watch', 'watch files and compile as needed', (arguments) ->
  project = new Project(process.cwd())
  project.watchAndBuild()

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
    "config.yml" : "config.yml"
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
    controller = arguments[0].toLowerCase()
    view = arguments[1].toLowerCase()
  else
    raise("Must supply a name for the controller and then view")

  copyFile = (from, to) ->
    ejs = fs.readFileSync(from).toString()
    fs.writeFileSync(Path.join(project.root, to), _.template(ejs, { project : project, controller: controller, view : view }))
    sys.puts " * Created #{to}"

  if !Path.existsSync("#{project.root}/app/views/#{controller}")
    fs.mkdirSync "#{project.root}/app/views/#{controller}", 0755

  if !Path.existsSync("#{project.root}/spec/views/#{controller}")
    fs.mkdirSync "#{project.root}/spec/views/#{controller}", 0755


  if !Path.existsSync("#{project.root}/app/templates/#{controller}")
    fs.mkdirSync "#{project.root}/app/templates/#{controller}", 0755

  copyFile "#{root}/templates/views/view.#{project.language()}", "app/views/#{controller}/#{view.capitalize()}View.#{project.language()}"
  copyFile "#{root}/templates/templates/template.hbs", "app/templates/#{controller}/#{view.capitalize()}Template.hbs"
  copyFile "#{root}/templates/views/spec.#{project.language()}", "spec/views/#{controller}/#{view.capitalize()}View.#{project.language()}"

# task 'spec', 'run the specs', (arguments) ->
#   project = new Project(process.cwd())
# 
#   sys.puts " * Running specs..."
#
#   jasmine = require('jasmine-node')
#   
#   runLogger = (runner, log) ->
#     if runner.results().failedCount == 0
#       process.exit 0
#     else
#       process.exit 1
#   
#   jasmine.executeSpecsInFolder "spec/models", runLogger, true, true

# No task was specified...

if !task.done
  sys.puts $usage
  process.exit()

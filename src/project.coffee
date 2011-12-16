sys = require('sys')

sys.puts "Capt:"

String.prototype.capitalize = ->
  this.charAt(0).toUpperCase() + this.substring(1).toLowerCase()

class Project
  constructor: (cwd) ->
    @cwd = cwd
    @root = cwd
  name : ->
    @cwd.replace(/.+\//,'')

  language : ->
    'js' # or 'coffee'

exports.Project = Project

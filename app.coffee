express = require 'express'
http = require 'http'
path = require 'path'
less = require 'less-middleware'
nunjucks = require 'nunjucks'
request = require 'request'
expressCoffee = require 'express-coffee'



app = express()

serverURL = 'localhost:3000'
if process.env.serverURL?
  serverURL = process.env.serverURL


app.configure ->
  env = new nunjucks.Environment(new nunjucks.FileSystemLoader('templates'))
  env.express(app)
  app.use express.errorHandler()

  app.use expressCoffee
    path: __dirname + '/public',
    live: !process.env.PRODUCTION,
    uglify: process.env.PRODUCTION

  app.use less
    src: path.join __dirname, 'public'
    once: true
    compress: true

  app.use express.favicon __dirname + '/public/images/favicon.ico'
  app.use express.static __dirname + '/public'

  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router

app.get '/', (req, res)->
  res.render 'index.html'

app.use (err, req, res, next)->
  throw err
  res.status 500
  res.render '500.html'

app.use (req, res)->
  res.status 404
  res.render '404.html'

http.createServer(app).listen process.env.PORT or 3000

console.log "Server running - on port " +(process.env.PORT or 3000)

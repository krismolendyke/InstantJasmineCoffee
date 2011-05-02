fs     = require 'fs'
{exec} = require 'child_process'
util   = require 'util'
uglify = require 'uglify-js'

prodSrcCoffeeDir     = 'prod/src/coffee-script'
testSrcCoffeeDir     = 'test/src/coffee-script'
nodeSrcCoffeeDir     = "#{prodSrcCoffeeDir}/node"

prodTargetJsDir      = 'js'
testTargetJsDir      = 'test/src/js'
nodeTargetJsDir      = 'node'

prodTargetFileName   = 'fcktrffc'
prodTargetCoffeeFile = "#{prodSrcCoffeeDir}/#{prodTargetFileName}.coffee"
prodTargetJsFile     = "#{prodTargetJsDir}/#{prodTargetFileName}.js"
prodTargetJsMinFile  = "#{prodTargetJsDir}/#{prodTargetFileName}.min.js"

prodCoffeeOpts = "--bare --output #{prodTargetJsDir} --compile #{prodTargetCoffeeFile}"
testCoffeeOpts = "--output #{testTargetJsDir}"
nodeCoffeeOpts = "--bare --output #{nodeTargetJsDir}"

prodCoffeeFiles = [
    'intro'
    'core'
    'outro'
]

distDir = "dist"
distFiles = [
    "index.html"
    "css"
    "img"
    "js"
]

option '-d', '--dist [DIR]', 'set the distribution directory'

task 'watch:all', 'Watch production and test CoffeeScript', ->
    invoke 'watch:test'
    invoke 'watch:node'
    invoke 'watch'
    
task 'build:all', 'Build production and test CoffeeScript', ->
    invoke 'build:test'
    invoke 'build:node'
    invoke 'build'    

task 'watch', 'Watch prod source files and build changes', ->
    invoke 'build'
    util.log "Watching for changes in #{prodSrcCoffeeDir}"

    for file in prodCoffeeFiles then do (file) ->
        fs.watchFile "#{prodSrcCoffeeDir}/#{file}.coffee", (curr, prev) ->
            if +curr.mtime isnt +prev.mtime
                util.log "Saw change in #{prodSrcCoffeeDir}/#{file}.coffee"
                invoke 'build'

task 'build', 'Build a single JavaScript file from prod files', ->
    util.log "Building #{prodTargetJsFile}"
    appContents = new Array remaining = prodCoffeeFiles.length
    util.log "Appending #{prodCoffeeFiles.length} files to #{prodTargetCoffeeFile}"
    
    for file, index in prodCoffeeFiles then do (file, index) ->
        fs.readFile "#{prodSrcCoffeeDir}/#{file}.coffee"
                  , 'utf8'
                  , (err, fileContents) ->
            handleError(err) if err
            
            appContents[index] = fileContents
            util.log "[#{index + 1}] #{file}.coffee"
            process() if --remaining is 0

    process = ->
        fs.writeFile prodTargetCoffeeFile
                   , appContents.join('\n\n')
                   , 'utf8'
                   , (err) ->
            handleError(err) if err
            
            exec "coffee #{prodCoffeeOpts}", (err, stdout, stderr) ->
                handleError(err) if err
                message = "Compiled #{prodTargetJsFile}"
                util.log message
                growl message
                # fs.unlink prodTargetCoffeeFile, (err) -> handleError(err) if err
                invoke 'uglify'                

task 'uglify', 'Minify and obfuscate', ->
    jsp = uglify.parser
    pro = uglify.uglify

    fs.readFile prodTargetJsFile, 'utf8', (err, fileContents) ->
        ast = jsp.parse fileContents  # parse code and get the initial AST
        ast = pro.ast_mangle ast # get a new AST with mangled names
        ast = pro.ast_squeeze ast # get an AST with compression optimizations
        final_code = pro.gen_code ast # compressed code here
    
        fs.writeFile prodTargetJsMinFile, final_code
        # fs.unlink prodTargetJsFile, (err) -> handleError(err) if err
        
        growl "Uglified #{prodTargetJsMinFile}"

task 'dist', 'Prepare distribution for deployment', (options) ->
    dir = options.dist or distDir
    fs.mkdir dir, '755'
    for file, index in distFiles then do (file, index) ->
        fs.link file, "#{dir}/#{file}"
    
task 'watch:test', 'Watch test specs and build changes', ->
    invoke 'build:test'
    util.log "Watching for changes in #{testSrcCoffeeDir}"
    
    fs.readdir testSrcCoffeeDir, (err, files) ->
        handleError(err) if err
        for file in files then do (file) ->
            fs.watchFile "#{testSrcCoffeeDir}/#{file}", (curr, prev) ->
                if +curr.mtime isnt +prev.mtime
                    coffee testCoffeeOpts, "#{testSrcCoffeeDir}/#{file}"

task 'build:test', 'Build individual test specs', ->
    util.log 'Building test specs'
    fs.readdir testSrcCoffeeDir, (err, files) ->
        handleError(err) if err
        for file in files then do (file) -> 
            coffee testCoffeeOpts, "#{testSrcCoffeeDir}/#{file}"

task 'watch:node', 'Watch node.js CoffeeScript', ->
    util.log "Watching for changes in #{nodeSrcCoffeeDir}"
    
    fs.readdir nodeSrcCoffeeDir, (err, files) ->
        handleError(err) if err
        for file in files then do (file) ->
            fs.watchFile "#{nodeSrcCoffeeDir}/#{file}", (curr, prev) ->
                if +curr.mtime isnt +prev.mtime
                    coffee nodeCoffeeOpts, "#{nodeSrcCoffeeDir}/#{file}"

task 'build:node', 'Build node.js CoffeeScript', ->
    util.log "Building node.js files"
    
    fs.readdir nodeSrcCoffeeDir, (err, files) ->
        handleError(err) if err
        for file in files then do (file) ->
            coffee nodeCoffeeOpts, "#{nodeSrcCoffeeDir}/#{file}"

coffee = (options = "", file) ->
    util.log "Compiling #{file}"
    exec "coffee #{options} --compile #{file}", (err, stdout, stderr) -> 
        handleError(err) if err
        growl "Compiled #{file}"

handleError = (error) -> 
    util.log error
    growl error
        
growl = (message = "") -> 
    options = {
        title: 'CoffeeScript'
        image: '/Users/kris/Desktop/Dropbox/Icons/CoffeeScript.png'
    }
    try require('growl').notify message, options

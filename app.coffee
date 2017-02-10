RootsUtil       = require 'roots-util'
js_pipeline     = require 'js-pipeline'
css_pipeline    = require 'css-pipeline'
dynamic_content = require 'dynamic-content'
browserify      = require 'roots-browserify'
image_pipeline  = require 'roots-image-pipeline'
statica         = require 'statica'
autoprefixer    = require 'autoprefixer'
jade            = require 'jade'
fs              = require 'fs'
marked          = require 'marked'
moment          = require 'moment'
highlight       = require 'highlight.js'

marked.setOptions
  gfm: true
  tables: true
  breaks: true
  pedantic: false
  sanitize: true
  smartLists: true
  smartypants: true
  highlight: (code) ->
    highlight.highlightAuto(code).value

module.exports =
  ignores: [
    'readme.md'
    '**/layout.*'
    '**/_*/*'
    '**/_*/**/*'
    '**/_*'
    '.gitignore'
    '**/drafts/**/*'
    'ship.*conf'
  ]

  browser:
    open: false

  before: (roots) ->
    helpers = new RootsUtil.Helpers
    helpers.project.remove_folders(roots.config.output)

  extensions: [
    image_pipeline(
      files: 'assets/img/**'
      compress: false
      resize: false
      output_webp: false
    )
    css_pipeline(files: 'assets/css/main.sass', postcss: true)
    dynamic_content(
      write: 'docs.json'
    )
    statica()
    browserify(
      files: 'assets/js/main.coffee'
      out: 'js/main.js'
      minify: true
      sourceMap: true
    )
  ]

  scss:
    sourcemap: true
    minify: true
    indentedSyntax: true

  postcss:
    use: [autoprefixer(browsers: ['last 3 versions'])]

  'coffee-script':
    sourcemap: true

  locals:
    render: fs.readFileSync
    md: marked

    icon: (name) ->
      fs.readFileSync "#{__dirname}/views/icons/_#{name}.svg"

    date: (date = null) ->
      if not date?
        return moment()

      moment date, 'YYYY-MM-DD hh:mm:ss'

    sort: (posts) -> posts.sort (a, b) -> a.seq - b.seq

  jade:
    pretty: true
    basedir: "#{__dirname}/views"

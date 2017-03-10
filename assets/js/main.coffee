Search = require './search'
Header = require './header'
Docs = require './docs'

class Zulu
  constructor: () ->
    @search = new Search
    @header = new Header
    @docs   = new Docs



new Zulu

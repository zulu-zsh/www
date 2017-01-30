Search = require './search'
Header = require './header'

class Zulu
  constructor: () ->
    @search = new Search
    @header = new Header

new Zulu

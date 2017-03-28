Promise   = require 'promise'
Fuse      = require 'fuse.js'
zenscroll = require 'zenscroll'
zenscroll.setup null, -1

require('es6-promise').polyfill()
require 'isomorphic-fetch'

###*
 * Methods for handling search input on the site
 *
 * @type {Search}
###
class Search
  ###*
   * Create the Search instance
   *
   * @return {Search}
  ###
  constructor: () ->
    @registerSearchInputListeners()

  ###*
   * Retrieve the package index JSON, and cache it
   * in local storage for five minutes, returning
   * the object in a Promise
   *
   * @return {Promise}
  ###
  getPackageIndex: () ->
    new Promise (resolve, reject) ->
      updatedAt = parseInt localStorage.getItem('package_index_updated_at')
      timestamp = new Date().getTime()

      if (updatedAt + 300) > timestamp
        json = localStorage.getItem('package_index')

        try
          resolve JSON.parse(json)
        catch err
          reject err

        return

      fetch 'https://zulu.sh/index/index.json'
        .then (response) ->
          response.json()

        .then (packages) ->
          localStorage.setItem 'package_index', JSON.stringify(packages)
          localStorage.setItem 'package_index_updated_at', timestamp
          resolve packages

        .catch (err) ->
          reject err

  ###*
   * Register listeners for handling search input and
   * other events
  ###
  registerSearchInputListeners: () =>
    input = document.querySelector '#search'
    close = document.querySelector '#nav--search-close'
    input.addEventListener 'change', @handleSearchInputKeyup
    input.addEventListener 'keyup',  @handleSearchInputKeyup
    input.addEventListener 'focus',  @handleSearchInputFocus
    input.addEventListener 'blur',   @handleSearchInputBlur
    close.addEventListener 'click',  @handleSearchInputClose

  ###*
   * Append a package to the list of search results
   *
   * @param  {object}      item    The package from the index
   * @param  {HTMLElement} results The results container
  ###
  appendSearchResult: (item, results) ->
    li = document.createElement 'li'

    a = document.createElement 'a'
    a.href = item.repository
    a.target = '_blank'
    a.innerHTML = item.name

    p = document.createElement 'p'
    p.innerHTML = item.description

    li.appendChild a
    li.appendChild p

    results.appendChild li

  ###*
   * Handle a search input keyup event
   *
   * @param  {Event} evt
  ###
  handleSearchInputKeyup: (evt) =>
    input = evt.target

    if not @intro?
      @intro = document.querySelector '.intro'

    key = evt.keyCode or evt.which or evt.charCode
    if key is 27
      @handleSearchInputClose evt
      input.blur()

    # If a value has been entered into the search input, overlay the
    # results pane over the page
    visible = document.body.classList.contains 'search-term-entered'
    if input.value.length > 0 and not visible
      zenscroll.to input, 150
      document.body.classList.add 'search-term-entered'

    # Retrieve the package index
    @getPackageIndex()
      # Search the package index and display the results on screen
      .then (packages) =>
        # Empty the results container
        results = document.querySelector '#results ul'
        results.innerHTML = ''

        # If no value is entered, or not packages are found,
        # then stop processing
        if not input.value or packages.length is 0
          return

        # Create the fuse instance
        options =
          threshold: 0.3
          keys: [{
            name: 'name'
            weight: 1
          }, {
            name: 'type'
            weight: 0.7
          }, {
            name: 'description'
            weight: 0.3
          }]
        fuse = new Fuse(packages, options)

        # Filter the results
        filtered = fuse.search(input.value)

        # Add the remaining packages to the list of search results
        @appendSearchResult item, results for item in filtered

      .catch (err) ->
        console.error err

        # Empty the results container
        results = document.querySelector '#results ul'
        results.innerHTML = ''

        # Create an error item and display it in the results pane
        li = document.createElement 'li'

        span = document.createElement 'span'
        span.innerHTML = 'Error'

        p = document.createElement 'p'
        p.innerHTML = 'An error occurred whilst fetching the index'

        li.appendChild span
        li.appendChild p

        results.appendChild li

  ###*
   * Handle a search input focus event
   *
   * @param  {Event} evt
  ###
  handleSearchInputFocus: (evt) ->
    document.body.classList.add 'search-focused'

  ###*
   * Handle a search input blur event
   *
   * @param  {Event} evt
  ###
  handleSearchInputBlur: (evt) ->
    if document.body.classList.contains 'search-term-entered'
      return evt.target.focus

    document.body.classList.remove 'search-focused'

  ###*
   * Handle a search input close button click event
   *
   * @param  {Event} evt
  ###
  handleSearchInputClose: (evt) ->
    evt.preventDefault()

    input = document.querySelector '#search'

    if document.body.classList.contains 'search-term-entered'
      document.body.classList.remove 'search-term-entered'
      document.body.classList.remove 'search-focused'

    input.value = null


module.exports = Search

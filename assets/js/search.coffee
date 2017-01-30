Promise = require 'promise'
zenscroll = require 'zenscroll'
zenscroll.setup null, -1

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
   * Compare search input against a package and
   * return a match score
   *
   * @param  {object} item  The package from the index
   * @param  {string} value The search term
   *
   * @return {int}          The match score
  ###
  getMatchScore: (item, value) ->
    item.score = 0

    item.score += switch
      when item.name is value                            then 10
      when item.name.substring(0, value.length) is value then 7
      when @fuzzyMatch item.name, value                  then 5
      when @fuzzyMatch item.type, value                  then 3
      when @fuzzyMatch item.description, value           then 1

    item.score

  ###*
   * Fuzzy match a search term against a string
   *
   * @param  {string} str     The string to match against
   * @param  {string} pattern The search term
   *
   * @return {boolean}        Whether or not a match is found
  ###
  fuzzyMatch: (str, pattern) ->
    if not pattern
      return false

    pattern = pattern.split ''
      .reduce (a, b) -> a + '.*' + b

    (new RegExp(pattern)).test(str)

  ###*
   * Retrieve the package index JSON, and cache it
   * in local storage for five minutes, returning
   * the object in a Promise
   *
   * @return {Promise}
  ###
  getPackageIndex: () ->
    new Promise (resolve, reject) ->
      updatedAt = localStorage.getItem 'package_index_updated_at'
      timestamp = new Date().getTime()

      if (updatedAt + 300) > timestamp
        json = localStorage.getItem('package_index')
        resolve JSON.parse(json)
        return

      fetch '//zulu.sh/index/index.json'
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

        # Store a match score against each of the packages in the index
        item.score = @getMatchScore(item, input.value) for item in packages

        # Remove packages which are not a match
        packages = packages.filter (item) -> item.score > 0

        # Sort packages by their match score
        packages.sort (a, b) -> b.score - a.score

        # Add the remaining packages to the list of search results
        @appendSearchResult item, results for item in packages

      .catch (err) ->
        document.body.innerHTML = err

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

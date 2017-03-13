###*
 * Provides methods for building the documentation menu
 *
 * @type {Docs}
###
module.exports = class Docs
  ###*
   * Start your engines!
   *
   * @return {Docs}
  ###
  constructor: () ->
    @renderNav()

  ###*
   * Renders the navigation in the sidebar
  ###
  renderNav: () =>
    # Get the documentation in JSON form
    @getDocs()
      .then (docs) ->
        # Loop through each of the documentation areas
        for key of docs
          do (key) ->
            # Find the list to put navigation items in
            list = document.querySelector ".docs--sidebar-nav-#{key}"
            if not list? or not docs[key]?
              return

            # Sort the items by sequence, then alphabetically
            docs[key].items.sort (a, b) ->
              if a.seq?
                return (a.seq - b.seq)

              return -1 if a.title < b.title
              return 1 if a.title > b.title
              return 0

            # Loop through each of the documentation items
            for item in docs[key].items
              do (item) ->
                # Create a list element and a link
                li = document.createElement 'li'
                a  = document.createElement 'a'

                # Populate the URL and title
                a.href      = item._url
                a.innerHTML = item.title

                # Add a class of active for the current URL
                if "#{item._url}/" is window.location.pathname
                  a.classList.add 'active'

                # Add the item to the list
                li.appendChild a
                list.appendChild li

  ###*
   * Retrieve the package index JSON, and cache it
   * in local storage for five minutes, returning
   * the object in a Promise
   *
   * @return {Promise}
  ###
  getDocs: () ->
    new Promise (resolve, reject) ->
      # Get the updated at timestamp
      updatedAt = localStorage.getItem 'documentation_updated_at'
      timestamp = new Date().getTime()

      # If we are within the cache time, get and parse the
      # cached documentation list
      if (updatedAt + 300) > timestamp
        json = localStorage.getItem 'documentation'
        resolve JSON.parse(json)
        return

      # Fetch the list from the stored JSON file
      fetch 'https://zulu.sh/docs.json'
        # Parse the JSON response
        .then (response) ->
          response.json()

        # Cache the response
        .then (response) ->
          localStorage.setItem 'documentation', JSON.stringify(response.docs)
          localStorage.setItem 'documentation_updated_at', timestamp
          resolve response.docs

        # Catch parsing errors
        .catch (err) ->
          reject err

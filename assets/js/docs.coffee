module.exports = class Docs
  constructor: () ->
    @renderNav()

  renderNav: () =>
    @getDocs()
      .then (docs) =>
        for key of docs
          do (key) ->
            list = document.querySelector ".docs--sidebar-nav-#{key}"
            if not list? or not docs[key]?
              return

            docs[key].items.sort (a, b) ->
              if a.seq?
                return (a.seq - b.seq)

              return -1 if a.title < b.title
              return 1 if a.title > b.title
              return 0

            for item in docs[key].items
              do (item) ->
                li = document.createElement 'li'
                a  = document.createElement 'a'

                a.href      = item._url
                a.innerHTML = item.title

                console.log item._url, window.location.pathname
                if "#{item._url}/" is window.location.pathname
                  a.classList.add 'active'

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
      updatedAt = localStorage.getItem 'documentation_updated_at'
      timestamp = new Date().getTime()

      if (updatedAt + 300) > timestamp
        json = localStorage.getItem 'documentation'
        resolve JSON.parse(json)
        return

      fetch 'http://localhost:1111/docs.json'
        .then (response) ->
          response.json()

        .then (response) ->
          localStorage.setItem 'documentation', JSON.stringify(response.docs)
          localStorage.setItem 'documentation_updated_at', timestamp
          resolve response.docs

        .catch (err) ->
          reject err

###*
 * Contains methods for handling scroll events on the header
 *
 * @type {Header}
###
class Header
  ###*
   * Create the Header instance
   *
   * @return {Header}
  ###
  constructor: () ->
    @header = document.querySelector '.nav'
    @registerHeaderScrollingListener()

  ###*
   * Register a listener which fires on scroll events
  ###
  registerHeaderScrollingListener: () ->
    window.addEventListener 'scroll', @fixHeaderOnScroll

  ###*
   * Fix the header to the top of the screen once the
   * scroll position reaches it
   *
   * @param  {Event} evt
  ###
  fixHeaderOnScroll: (evt) ->
    if not @header?
      @header = document.querySelector '.nav'

    if not @intro?
      @intro = document.querySelector '.intro'

    if not @intro?
      document.body.classList.add 'scrolled'
      return

    y = window.pageYOffset

    if y > @intro.clientHeight
      document.body.classList.add 'scrolled'
    else
      document.body.classList.remove 'scrolled'



module.exports = Header

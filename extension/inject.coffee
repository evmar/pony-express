# This script is injected into the page, and replaces it with the custom
# content.

hijack = ->
  if 'hijacked' of window
    # This comes up when you pushState a new URL.
    console.log 'already hijacked ' + document.location
    return

  window.hijacked = true
  document.open()
  document.write(ui)

hijack()

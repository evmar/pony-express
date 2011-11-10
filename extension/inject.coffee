# This script is injected into the page, and replaces it with the custom
# content.

hijack = ->
  if 'hijacked' of ponyExpress
    # This comes up when you pushState a new URL.
    console.log 'already hijacked ' + document.location
    return

  ponyExpress.hijacked = true
  document.open()
  document.write("<!DOCTYPE html>");
  document.write("<script src='" + chrome.extension.getURL('ui.js') + "'></script>");
  # Brain-bender: we want to write the 'ui' var from the above script.
  document.write("<script>document.write(ui);</script>")

hijack() if ponyExpress.isPiperMail document.location.href

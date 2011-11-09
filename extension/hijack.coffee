# Code shared between the hijack background page and the code injected
# into the hijacked page.

this.isPiperMail = (url) ->
  # Parse URL using the DOM, yikes!
  a = document.createElement 'a'
  a.href = url

  matches = a.pathname.match ///
    /pipermail/
    ([^/]+)/
    (.*)
  ///

  if matches
    [_, list, rest] = matches
    return null if list == 'extension'
  else if a.host.match /^lists./
    # Get more aggressive on lists.foobar.org URLs.
    matches = a.pathname.match ///
      /archives/
      ([^/]+)/
      (.*)
    ///
    return null unless matches
    [_, list, rest] = matches
  else
    return null

  if a.protocol == 'file:' and a.pathname.match /\/$/
    # Cross-origin checks from file:/// URLs showing directories
    # are screwed in Chrome.
    return null

  breakdown =
    url: url
    base: url.substr(0, url.length - rest.length)
    list: list

  parts = rest.split '/'
  if parts.length == 2
    [breakdown.month, rest] = parts
    switch rest
      when '', 'thread.html'  # ignore
      else breakdown.thread = rest
  else if parts.length == 1
    if parts[0] != 'index.html'
      breakdown.month = parts[0]
  else
    return null

  return breakdown


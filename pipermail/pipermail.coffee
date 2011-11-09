
# Set this to non-zero to make the resource-fetching functions
# behave as if they took extra milliseconds to complete.
simulatedLatency = 0

filterNulls = (l) ->
  i for i in l when i

extractIter = (query, node) ->
  node ||= document
  document.evaluate query, node, null,
      XPathResult.UNORDERED_NODE_ITERATOR_TYPE, null

extract = (query, node) ->
  node ||= document
  r = document.evaluate query, node, null,
      XPathResult.ORDERED_NODE_ITERATOR_TYPE, null
  while i = r.iterateNext()
    i

fetch = (url, callback) ->
  xhr = new XMLHttpRequest
  xhr.open 'GET', url
  xhr.onreadystatechange = ->
    if xhr.readyState is 4
      if xhr.status in [0, 200]
        callback xhr.responseText
      else
        throw new Error "error loading #{url}"
  xhr.send null


loadHTML = (url, callback) ->
  pipermail.status 'Loading...'
  iframe = document.createElement 'iframe'
  iframe.style.display = 'none'
  iframe.onload = ->
    pipermail.status null
    callback iframe.contentDocument
    document.body.removeChild iframe
  iframe.src = url
  document.body.appendChild iframe
  # TODO: add a timeout here to remove this if it takes too long,
  # because we never get called back on errors?  Ugly!

if simulatedLatency
  loadHTML = do (loadHTML) -> (url, callback) ->
      pipermail.status 'Loading...'
      setTimeout (-> loadHTML url, callback), simulatedLatency

extractIndexURLs = (doc) ->
  r = extractIter '//td/a', doc
  filterNulls (while a = r.iterateNext()
    a.href if a.href.match /thread.html$/)

loadIndex = (url, callback) ->
  loadHTML url + 'index.html', (doc) ->
    urls = extractIndexURLs doc
    callback urls


fillThread = (cb) ->
  loadMessage this.url, (msg) =>
    if msg
      this.header = msg.header
      this.body = msg.body
      cb true
    else
      cb false


extractThread = (li) ->
  elems = (c for c in li.children when c.nodeType == Node.ELEMENT_NODE)
  return if elems[0].tagName == 'B'  # Avoid "Messages sorted by" heading.

  thread =
    url: elems[0].href
    header:
      subject: elems[0].innerText
      from: [elems[2].innerText, '']
    fill: fillThread

  if elems.length > 3
    thread.children = extractThreads elems[3]
  thread

extractThreads = (ul) ->
  threads = []
  for li in ul.children
    t = null
    switch li.tagName
      when 'LI' then t = extractThread li
      when 'UL' then t = {children:extractThreads li}
      else continue
    threads.push t if t
  threads if threads.length > 0

extractThreadsFromDoc = (doc) ->
  r = extractIter '//body/ul', doc
  while ul = r.iterateNext()
    threads = extractThreads ul
    return threads if threads

loadMonth = (url, callback) ->
  loadHTML url, (doc) ->
    threads = extractThreadsFromDoc doc
    callback threads


extractMessage = (doc) ->
  n = doc.body.firstElementChild
  while n and not body
    switch n.tagName.toLowerCase()
      when 'h1'
        subject = n.innerText
      when 'b'
        author = n.innerText
      when 'a'
        address = n.innerText.replace(/\sat\s/, '@')
      when 'i'
        date = n.innerText # FIXME
      when 'pre'
        body = n.innerText

    n = n.nextElementSibling

  message =
    header:
      subject: subject
      from: [author, address]
      date: date
    body: body

  return message

loadMessage = (url, callback) ->
  loadHTML url, (doc) ->
    callback (if doc then extractMessage doc else null)

this.pipermail =
  loadIndex: loadIndex
  loadMonth: loadMonth
  loadMessage: loadMessage
  status: (msg) -> console.log 'Status: ' + msg if msg

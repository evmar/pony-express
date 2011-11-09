
# Turn on to make URL bar reflect real URL.
# Makes debugging annoying, though.
kUsePushState = false

state =
  selected: null

# Expose state globally for ease of debugging.
this.state = state

dom_threadlist = null
urlToThread = {}

dom = (name, attrs, content) ->
  node = document.createElement name
  switch typeof attrs
    when 'string'
      content = attrs
      attrs = null
    when 'object'
      if attrs instanceof Array or attrs instanceof HTMLElement
        content = attrs
        attrs = null
    when 'undefined'
      return node
  if attrs
    for key, val of attrs
      node[key] = val

  if content instanceof Array
    for n in content
      if typeof n == 'string'
        n = document.createTextNode n
      node.appendChild n
  else if content instanceof HTMLElement or content instanceof Text
    node.appendChild content
  else if content
    node.innerText = content
  return node

domEmail = (from) ->
  [name, addr] = from

  if not addr
    return dom 'span', {className:'email'}, name

  a = dom 'a', {href:'#FIXME', className:'email'}
  if name
    a.title = addr
    a.innerText = name
  else
    a.appendChild dom 'tt', addr
  a


cleanupSubject = (subject) ->
  subject = subject.replace '\n', ''
  subject = subject.replace /^re: ?/i, ''
  subject = subject.replace /^\[\S+\] /, ''
  subject

buildThread = (thread, indent) ->
  indent ||= 0

  urlToThread[thread.url] = thread

  row = dom 'a', {className:'entry'}
  row.href = thread.url
  row.onclick = (event) ->
    if event.button == 0
      event.preventDefault()
      showMessage thread

  if thread.header and (not indent or not thread.parent.header)
    subject = cleanupSubject thread.header.subject
    row.appendChild dom 'span', {className:'subject'}, subject
    row.appendChild document.createTextNode ' '

  if thread.header
    row.appendChild domEmail thread.header.from

  if indent
    row.style.paddingLeft = (indent+1) + 'em'
  else
    row.className += ' toplevel'

  thread.dom = row
  row.thread = thread

  container = dom 'div', row

  if thread.children
    for child in thread.children
      child.parent = thread
      container.appendChild buildThread child, indent + 1

  return container


showMessage = (msg, noHistory) ->
  if state.selected
    sel = state.selected
    sel.dom.className = sel.dom.className.replace(' selected', '')
  state.selected = msg
  msg.dom.className += ' selected'

  scrollIn dom_threadlist, msg.dom

  if kUsePushState && not noHistory
    history.pushState null, '', msg.url

  if 'body' of msg
    domMessageSync msg
  else
    msg.fill (success) ->
      # Once the message has been fetched, check again whether
      # it's the one we want to display, in case we've scrolled
      # past this message while waiting.
      if msg == state.selected
        domMessageSync (if success then msg else null)

markupText = (node, text) ->
  for line in text.split /\n/
    n = document.createTextNode(line + '\n')
    if line.match /^>/
      n = dom 'span', {className:'quote'}, n
    node.appendChild n

domMessageSync = (msg) ->
  container = document.getElementById('message')
  container.innerHTML = ''

  if not msg
    container.innerHTML = '(error loading message)'
    return

  table = dom('table')
  table.appendChild dom 'tr', [
    dom('td', {className:'header-key'}, 'From:'),
    dom('td', domEmail(msg.header.from))
  ]

  dom_header = dom 'div', {id:'message-header'}, [
    dom('h1', {className:'subject'}, msg.header.subject),
    table
  ]
  container.appendChild dom_header

  dom_body = dom 'pre', {id:'message-body', className:'plaintext'}
  markupText dom_body, msg.body
  container.appendChild dom_body

scrollIn = (container, node) ->
  kMargin = 5
  if node.offsetTop < container.scrollTop + kMargin or
    node.offsetTop + node.offsetHeight + kMargin >
      container.scrollTop + container.offsetHeight
    container.scrollTop = node.offsetTop - kMargin

findIndex = (t) ->
  parent = t.parent
  for i in [0..parent.children.length]
    return i if parent.children[i] == t
  return -1

nextVisible = (sel) ->
  if sel.children
    return sel.children[0]
  while sel
    sibling = nextSibling sel
    return sibling if sibling
    sel = sel.parent
  return null

nextSibling = (sel) ->
  i = findIndex sel
  return sel.parent?.children[i+1]

lastChild = (sel) ->
  if sel.children
    return lastChild sel.children[sel.children.length-1]
  return sel

prevVisible = (sel) ->
  i = findIndex sel
  if i == 0
    parent = sel.parent
    parent = null if not parent.dom  # Filter out pseudo-root.
    return parent
  prev = sel.parent?.children[i-1]
  return lastChild prev if prev

prevSibling = (sel) ->
  i = findIndex sel
  return sel.parent?.children[i-1]

maybeShow = (sel) ->
  showMessage sel if sel

kKeyBindings =
  j: -> maybeShow nextVisible state.selected
  J: -> maybeShow nextSibling state.selected
  k: -> maybeShow prevVisible state.selected
  K: -> maybeShow prevSibling state.selected

document.addEventListener 'keypress', (event) ->
  key = String.fromCharCode event.keyCode
  if key of kKeyBindings
    kKeyBindings[key]()
    event.preventDefault()

# XXX don't use global namespace for exposed API.
this.showThreadByURL = (url) ->
  thread = urlToThread[url]
  console.log url, thread
  showMessage thread, true if thread

window.onpopstate = (event) ->
  this.showThreadByURL document.location

this.buildThreadList = (threads) ->
  dom_threadlist = document.getElementById 'threadlist'
  root = {children:threads}
  for thread in threads
    thread.parent = root
    dom_threadlist.appendChild buildThread thread


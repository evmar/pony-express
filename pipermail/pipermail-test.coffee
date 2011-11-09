
module 'Pipermail'

testdata = (path) -> '../testdata/' + path

asyncTest 'loadIndex', ->
  pipermail.loadIndex testdata('webkit-dev/'), (urls) ->
    equals urls.length, 77, 'extracted urls'
    ok urls[0].match(/2011-October\/thread\.html$/), 'got month'
    start()

asyncTest 'loadMonth webkit', ->
  pipermail.loadMonth testdata('webkit-dev/2011-October/thread.html'), (threads) ->
    equals threads.length, 79, 'extracted threads'
    equals threads[0].children, undefined, 'no child on first thread'
    thread = threads[2]
    equals thread.children.length, 1, 'child on third thread'
    equals thread.header.from[0], 'Balazs Kelemen', 'third thread author'
    start()

asyncTest 'loadMonth wayland', ->
  pipermail.loadMonth testdata('wayland-devel/2011-November/thread.html'), (threads) ->
    equals threads.length, 3, 'extracted threads'
    start()

asyncTest 'loadMonth nouveau', ->
  pipermail.loadMonth testdata('nouveau-thread.html'), (threads) ->
    equals threads.length, 2, 'extracted threads'
    start()

asyncTest 'loadMessage', ->
  pipermail.loadMessage testdata('webkit-dev/2011-October/018128.html'), (message) ->
    equals message.header.subject, '[webkit-dev] The Questiong of Meta-tag'
    equals message.header.from[1], 'jyotaku@gmail.com'
    ok message.body.match /^Hi everybody\n/
    start()

###
# Did this test ever work?  It appears to silently fail.
# It appears there's no callback when iframe loads fail.  :(
asyncTest 'loadMessage failure', ->
  pipermail.loadMessage 'http://localhost/nosuchfile.html', (message) ->
    equals message, null
    start()
###

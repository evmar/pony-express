# Tests for hijack.coffee.

module 'Extension'

test 'isPiperMail', ->
  pm = isPiperMail 'file:///test/pony-express/testdata/webkit-dev/index.html'
  notEqual pm, null, "fire on local testing page"
  equals pm.list, 'webkit-dev'
  equals pm.base, 'file:///test/pony-express/testdata/webkit-dev/'

  pm = isPiperMail 'file:///test/pipermail.html'
  equals pm, null, "don't match random occurrences of pipermail in URLs"

  pm = isPiperMail 'file:///test?url=/pipermail/foo/bar.html'
  equals pm, null, "don't match query params"

  pm = isPiperMail 'https://lists.webkit.org/pipermail/webkit-dev/'
  notEqual pm, null, "fire on webkit site"

  pm = isPiperMail 'http://lists.freedesktop.org/archives/wayland-devel/'
  notEqual pm, null, "fire on wayland site"

test 'isPiperMail thread', ->
  pm = isPiperMail 'http://lists.freedesktop.org/archives/wayland-devel/2011-October/001449.html'
  notEqual pm, null
  equal pm.url, 'http://lists.freedesktop.org/archives/wayland-devel/2011-October/001449.html'
  equal pm.base, 'http://lists.freedesktop.org/archives/wayland-devel/'
  equal pm.list, 'wayland-devel'
  equal pm.month, '2011-October'
  equal pm.thread, '001449.html'

test 'isPiperMail month', ->
  pm = isPiperMail 'http://lists.freedesktop.org/archives/wayland-devel/2011-October/'
  notEqual pm, null
  equal pm.base, 'http://lists.freedesktop.org/archives/wayland-devel/'
  equal pm.list, 'wayland-devel'
  equal pm.month, '2011-October'
  equal pm.thread, null

test 'isPiperMail month/thread', ->
  pm = isPiperMail 'http://lists.freedesktop.org/archives/wayland-devel/2011-October/thread.html'
  notEqual pm, null
  equal pm.base, 'http://lists.freedesktop.org/archives/wayland-devel/'
  equal pm.list, 'wayland-devel'
  equal pm.month, '2011-October'
  equal pm.thread, null

test 'isPiperMail file url special cases', ->
  equal isPiperMail 'file:///pipermail/fff/', null
  equal isPiperMail 'file:///pipermail/fff/2011-October/', null

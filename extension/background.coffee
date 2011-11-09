# Code that runs specifically as part of the background page:
# Calls into the Chrome API to hijack the appropriate URLs.

hijack = (tab, context) ->
  console.log 'hijacking', tab, context
  chrome.tabs.executeScript tab.id, {file:'ui.js'}, ->
    chrome.tabs.executeScript tab.id, {file:'inject.js'}, ->
      console.log 'injected'

chrome.tabs.onUpdated.addListener (tabId, info, tab) ->
  # XXX figure out whether to fire on loading or complete
  if info.status == 'loading'
    context = isPiperMail tab.url
    hijack tab, context if context

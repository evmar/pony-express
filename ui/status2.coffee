
widget = null

makeWidget = ->
  return if widget
  widget = document.createElement 'div'
  widget.id = 'status2'
  document.body.appendChild(widget)

show = (text) ->
  makeWidget()
  widget.style.opacity = 1
  widget.innerText = text
  return widget

clear = ->
  widget.style.opacity = 0

this.status2 =
  show: show
  clear: clear

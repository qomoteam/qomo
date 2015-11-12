window.define = (a, b) -> {}

window._hooks = {}

window.within = (controller, action, onready) ->
  actions = _hooks[controller] || {}
  _.each action.split(','), (e) ->
    e = e.trim()
    actions[e] = onready
    _hooks[controller] = actions

window.app = gon

$ ->
  return unless _hooks[app.controller]
  return unless  _hooks[app.controller][app.action]
  _hooks[app.controller][app.action]()

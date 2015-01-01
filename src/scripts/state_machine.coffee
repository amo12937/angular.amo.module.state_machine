"use strict"

do (moduleName = "amo.module.state_machine") ->
  angular.module moduleName, ["ng"]
  .factory "#{moduleName}.StateSetter", ->
    ->
      currentState = null
      changing = false

      self = (state) ->
        return if changing
        changing = true
        currentState?.Exit?()
        currentState = state
        currentState?.Entry?()
        changing = false
        return

      self.defaultAction = ->

      self.getFsm = (initState) ->
        currentState = initState
        fsm = -> currentState
        fsm.changing = -> changing
        return fsm

      return self

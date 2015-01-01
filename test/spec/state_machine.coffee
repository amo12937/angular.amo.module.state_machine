"use strict"

do (moduleName = "amo.module.state_machine") ->
  describe "#{moduleName} の仕様", ->
    beforeEach module moduleName

    describe "StateSetter は", ->
      Fsm = null
  
      beforeEach ->
        inject ["#{moduleName}.StateSetter", (StateSetter) ->
          Fsm = (action = {}) ->
            setState = StateSetter()
    
            class DefaultState
              Entry: setState.defaultAction
              Exit: setState.defaultAction
              toState1: setState.defaultAction
              toState2: setState.defaultAction
              toEnd: setState.defaultAction
              isInit: -> false
              isState1: -> false
              isState2: -> false
              isDone: -> false
    
            INIT = new class extends DefaultState
              toState1: -> setState STATE1
              isInit: -> true
            STATE1 = new class extends DefaultState
              toState2: -> setState STATE2
              isState1: -> true
            STATE2 = new class extends DefaultState
              Entry: -> action.entryState2?()
              Exit: -> action.exitState2?()
              toState1: -> setState STATE1
              toEnd: -> setState DONE
              isState2: -> true
            DONE = new class extends DefaultState
              isDone: -> true
    
            return setState.getFsm INIT
        ]

      it "state を変更するための関数を返す", ->
        fsm = Fsm()
        expect(fsm().isInit()).toBe true
        fsm().toState1()
        expect(fsm().isState1()).toBe true

      it "defaultAction は状態を変化させない", ->
        fsm = Fsm()
        expect(fsm().isInit()).toBe true
        fsm().toState2()
        expect(fsm().isState2()).toBe false

      it "state 変更時に Entry, Exit が呼ばれる", ->
        fsm = Fsm action =
          entryState2: jasmine.createSpy "entryState2"
          exitState2: jasmine.createSpy "exitState2"

        fsm().toState1()
        expect(action.entryState2).not.toHaveBeenCalled()
        fsm().toState2()
        expect(action.entryState2).toHaveBeenCalled()

        expect(action.exitState2).not.toHaveBeenCalled()
        fsm().toState1()
        expect(action.exitState2).toHaveBeenCalled()

      it "fsm.changing() は Entry, Exit 内でのみ true である", ->
        fsm = Fsm
          entryState2: ->
            expect(fsm.changing()).toBe true
          exitState2: ->
            expect(fsm.changing()).toBe true
        fsm().toState1()
        expect(fsm.changing()).toBe false
        fsm().toState2()
        expect(fsm.changing()).toBe false
        fsm().toState1()
        expect(fsm.changing()).toBe false

      it "Entry, Exit の中での state 変更は無視される", ->
        fsm = Fsm
          entryState2: ->
            expect(fsm().isState2()).toBe true
            fsm().toEnd()
            expect(fsm().isState2()).toBe true
          exitState2: ->
            expect(fsm().isState2()).toBe true
            fsm().toState1()
            expect(fsm().isState2()).toBe true

        fsm().toState1()
        expect(fsm().isState1()).toBe true
        fsm().toState2()
        expect(fsm().isState2()).toBe true
        fsm().toEnd()
        expect(fsm().isDone()).toBe true

(function() {
  "use strict";
  (function(moduleName) {
    return angular.module(moduleName, ["ng"]).factory("" + moduleName + ".StateSetter", function() {
      return function() {
        var changing, currentState, self;
        currentState = null;
        changing = false;
        self = function(state) {
          if (changing) {
            return;
          }
          changing = true;
          if (currentState != null) {
            if (typeof currentState.Exit === "function") {
              currentState.Exit();
            }
          }
          currentState = state;
          if (currentState != null) {
            if (typeof currentState.Entry === "function") {
              currentState.Entry();
            }
          }
          changing = false;
        };
        self.defaultAction = function() {};
        self.getFsm = function(initState) {
          var fsm;
          currentState = initState;
          fsm = function() {
            return currentState;
          };
          fsm.changing = function() {
            return changing;
          };
          return fsm;
        };
        return self;
      };
    });
  })("amo.module.state_machine");

}).call(this);

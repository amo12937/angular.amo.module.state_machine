# angular.amo.module.state_machine

ステートマシンを作るためのヘルパーを提供する

# インストール方法
```
bower install -S angular.amo.module.state_machine
```

```haml:index.haml
%script(src="bower_components/angular.amo.module.state_machine/dist/js/state_machine.min.js")
```

# 使い方

## StateSetter
StateSetter は State 変更のための汎用的な関数を提供する。

```coffee
angular.module "yourApp", ["amo.module.state_machine"]
.factory "SomeFsm", ["amo.module.state_machine.StateSetter", (StateSetter) ->
  (action = {}) ->
    setState = StateSetter()
  
    class DefaultState
      Entry: setState.defaultAction
      Exit: setState.defaultAction
      toState1: setState.defaultAction
      toState2: setState.defaultAction
      toEnd: setState.defaultAction
  
    INIT = new class extends DefaultState
      toState1: -> setState STATE1
    STATE1 = new class extends DefaultState
      toState2: -> setState STATE2
    STATE2 = new class extends DefaultState
      Entry: -> action.entryState2?()
      Exit: -> action.exitState2?()
      toState1: -> setState STATE1
      toEnd: -> setState DONE
    DONE = new class extends DefaultState
  
    return setState.getFsm INIT
]
```

### `setState.defaultAction`
何もしない関数を返す。

### `setState.getFsm initState`
外部公開用の fsm を返す。
fsm は、それ自身が 関数となっており、現在の ステート を返すようになっている。そのため、これを使う場では下記のようにしてステートを変更することが出来る。

```
angular.module "yourApp"
.factory "AnotherObj", ["SomeFsm", (SomeFsm) ->
  fsm = SomeFsm()
  fsm().toState1()
  ...
]
```

### `fsm.changing`
ステートが変更中かどうかを返す。
この関数は Entry, Exit 内で呼ばれた場合に true, それ以外の場所では false を返す。
また、この値が true の時には ステートを変更できない。


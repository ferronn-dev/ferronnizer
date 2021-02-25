local T = require('testing')

T.RunTests({
  function(state)
    local button = state.frames['MountButton']
    button:Click()
    T.assertEquals('macro', button:GetAttribute('type'))
    T.assertEquals('/dismount', button:GetAttribute('macrotext'))
    T.assertEquals({{ macro = '/shrug [@none]' }}, state.commands)
  end,
  function(state)
    state.inCombat = true
    state.frames['MountButton']:Click()
    T.assertEquals({{ macro = '/dismount' }}, state.commands)
  end,
  function(state)
    state.isMounted = true
    state.frames['MountButton']:Click()
    T.assertEquals({{ macro = '/dismount' }}, state.commands)
  end,
  function(state)
    state.knownSpells = {13819}
    state.frames['MountButton']:Click()
    T.assertEquals({{ macro = '/stand\n/cancelform\n/cast spell13819' }}, state.commands)
  end,
  function(state)
    state.inventory = { [8631] = 1 }
    state.frames['MountButton']:Click()
    T.assertEquals({{ macro = '/stand\n/cancelform\n/use item:8631' }}, state.commands)
  end,
})

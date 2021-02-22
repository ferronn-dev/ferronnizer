local T = require('testing')

T.RunTests({
  function(state)
    T.assertEquals({}, state.cvars)
    T.assertEquals(nil, state.consoleKey)
  end,
  function(state)
    state:SendEvent('VARIABLES_LOADED')
    T.assertEquals(1, state.cvars.autoLootDefault)
    T.assertEquals('F12', state.consoleKey)
  end,
})

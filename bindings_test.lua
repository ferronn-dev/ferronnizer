local T = require('testing')

T.RunTests({
  function(state)
    state:SendEvent('PLAYER_LOGIN')
    T.assertEquals(true, next(state.bindings) ~= nil, 'missing bindings')
  end,
})

local T = require('testing')

T.RunTests({
  function(state)
    state:SendEvent('PLAYER_LOGIN')
    state:SendEvent('PLAYER_ENTERING_WORLD')
  end,
})

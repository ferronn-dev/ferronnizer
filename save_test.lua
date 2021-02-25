local T = require('testing')

T.RunTests({
  function(state)
    state:SendEvent('PLAYER_LOGIN')
    state:SendEvent('PLAYER_ENTERING_WORLD')
    state:SendEvent('PLAYER_LOGOUT')
  end,
})

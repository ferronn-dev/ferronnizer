local T = require('testing')

T.RunTests({
  function(state)
    state:SendEvent('PLAYER_LOGIN')
  end,
})

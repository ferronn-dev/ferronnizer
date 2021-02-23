local T = require('testing')

T.RunTests({
  function(state)
    state:SendEvent('ADDON_LOADED', 'moo')
    state:SendEvent('PLAYER_ENTERING_WORLD')
  end,
})

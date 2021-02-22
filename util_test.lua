local T = require('testing')

T.RunTests({
  function(state, _, env)
    state.localTime = 100
    state.serverTime = 200
    T.assertEquals(180, env.LocalToServer(80))
    T.assertEquals(80, env.ServerToLocal(180))
    T.assertEquals(0, env.LocalToServer(0))
    T.assertEquals(0, env.ServerToLocal(0))
  end,
})

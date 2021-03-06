local T = require('testing')

T.RunTests({
  function(state, _, env)
    local got = {}
    local send = env.RegisterPartyChat(function(...)
      table.insert(got, {...})
    end)
    state:SendEvent('ADDON_LOADED', 'moo')
    send('a')
    send(42, 'b')
    local want = { {'Kewhand', 'a'}, {'Kewhand', 42, 'b'} }
    T.assertEquals(want, got)
  end,
  function(state, _, env, _G)
    local got = {}
    local send = env.RegisterPartyChat(function(...)
      table.insert(got, {...})
    end)
    state:SendEvent('ADDON_LOADED', 'moo')
    state.inGroup = true
    send('a')
    send(42, 'b')
    state:TickUpdate(10000)
    T.assertEquals({}, got)
    T.assertEquals(2, #state.sentChats)
    for _, c in ipairs(state.sentChats) do
      state:SendEvent('CHAT_MSG_ADDON',
          c.prefix, c.message, c.chatType, _G.UnitName('player'), c.target)
    end
    local want = { {'Kewhand', 'a'}, {'Kewhand', '42', 'b'} }
    T.assertEquals(want, got)
  end,
})

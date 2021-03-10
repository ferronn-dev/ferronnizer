describe('partychat', function()
  it('invokes callbacks directly when not in a group', function()
    local state, _, addon = require('addonloader')()
    local got = {}
    local send = addon.RegisterPartyChat(function(...)
      table.insert(got, {...})
    end)
    state:SendEvent('ADDON_LOADED', 'moo')
    send('a')
    send(42, 'b')
    local want = { {'Kewhand', 'a'}, {'Kewhand', 42, 'b'} }
    assert.same(want, got)
  end)
  it('invokes callbacks via party chat when in group', function()
    local state, env, addon = require('addonloader')()
    local got = {}
    local send = addon.RegisterPartyChat(function(...)
      table.insert(got, {...})
    end)
    state:SendEvent('ADDON_LOADED', 'moo')
    state.inGroup = true
    send('a')
    send(42, 'b')
    state:TickUpdate(10000)
    assert.same({}, got)
    assert.same(2, #state.sentChats)
    for _, c in ipairs(state.sentChats) do
      state:SendEvent('CHAT_MSG_ADDON',
          c.prefix, c.message, c.chatType, env.UnitName('player'), c.target)
    end
    local want = { {'Kewhand', 'a'}, {'Kewhand', '42', 'b'} }
    assert.same(want, got)
  end)
end)

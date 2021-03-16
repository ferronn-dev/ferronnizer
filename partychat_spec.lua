describe('partychat', function()
  it('invokes callbacks directly when not in a group', function()
    local got = {}
    local send = wow.addon.RegisterPartyChat(function(...)
      table.insert(got, {...})
    end)
    wow.state:SendEvent('ADDON_LOADED', 'moo')
    send('a')
    send(42, 'b')
    local want = { {'Kewhand', 'a'}, {'Kewhand', 42, 'b'} }
    assert.same(want, got)
  end)
  it('invokes callbacks via party chat when in group', function()
    local got = {}
    local send = wow.addon.RegisterPartyChat(function(...)
      table.insert(got, {...})
    end)
    wow.state:SendEvent('ADDON_LOADED', 'moo')
    wow.state.inGroup = true
    send('a')
    send(42, 'b')
    wow.state:TickUpdate(10000)
    assert.same({}, got)
    assert.same(2, #wow.state.sentChats)
    for _, c in ipairs(wow.state.sentChats) do
      wow.state:SendEvent('CHAT_MSG_ADDON',
          c.prefix, c.message, c.chatType, wow.env.UnitName('player'), c.target)
    end
    local want = { {'Kewhand', 'a'}, {'Kewhand', '42', 'b'} }
    assert.same(want, got)
  end)
end)

describe('save', function()
  it('saves something', function()
    wow.state:SendEvent('PLAYER_LOGIN')
    wow.state:SendEvent('PLAYER_ENTERING_WORLD')
    wow.state:SendEvent('PLAYER_LOGOUT')
    local expected = {
      bags = {},
      class = 'PALADIN',
      equipment = {},
      level = 42,
      name = 'Kewhand',
      race = 'Human',
      realm = 'Realm',
      talents = {},
      url = 'https://classic.wowhead.com/gear-planner/paladin/human/AioA',
    }
    assert.same(expected, wow.env.mooPlayerData)
  end)
end)

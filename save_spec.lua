describe('save', function()
  it('saves something', function()
    wow.state:SendEvent('PLAYER_LOGIN')
    wow.state:SendEvent('PLAYER_ENTERING_WORLD')
    wow.state:SendEvent('PLAYER_LOGOUT')
    local function ifClassic(k)
      return WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and k or nil
    end
    local expected = {
      bags = {},
      class = 'PALADIN',
      equipment = {},
      level = 42,
      name = 'Kewhand',
      race = 'Human',
      realm = 'Realm',
      talents = ifClassic({}),
      url = ifClassic('https://classic.wowhead.com/gear-planner/paladin/human/AioA'),
    }
    assert.same(expected, wow.env.mooPlayerData)
  end)
end)

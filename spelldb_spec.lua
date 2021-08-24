describe('spell db', function()
  it('knows about all spell actions', function()
    local knownBad = {
      ['!Shoot'] = true,
      ['Cold Snap'] = true,
      ['Desperate Prayer'] = true,
      ['Divine Intervention'] = true,
      ['Divine Favor'] = true,
      ['Escape Artist'] = true,
      ['Evocation'] = true,
      ['Gift of the Naaru'] = true,
      ['Inner Focus'] = true,
      ['Lay on Hands'] = true,
      ['Perception'] = true,
    }
    local seenBad = {}
    for fullname, actions in pairs(wow.addon.ClassActionSpecs) do
      for _, action in pairs(actions) do
        if action.spell then
          if knownBad[action.spell] then
            seenBad[action.spell] = true
          elseif not wow.addon.SpellDB[action.spell] then
            error(fullname .. ': ' .. action.spell)
          end
        end
      end
    end
    assert.same(knownBad, seenBad)
  end)
  it('does not duplicate spell ids', function()
    -- TODO make this table empty instead
    local expected = ({
      [2] = {
        ['Bite'] = true,
        ['Claw'] = true,
        ['Consecration'] = true,
        ['Dash'] = true,
        ['Dive'] = true,
        ['Immolate'] = true,
        ['Intimidation'] = true,
        ['Screech'] = true,
      },
      [5] = {
        ['Bite'] = true,
        ['Claw'] = true,
        ['Dash'] = true,
        ['Dive'] = true,
        ['Gore'] = true,
        ['Greater Heal'] = true,
        ['Immolate'] = true,
        ['Intimidation'] = true,
        ['Screech'] = true,
      },
    })[wow.env.WOW_PROJECT_ID]
    local actual = {}
    for name, ranks in pairs(wow.addon.SpellDB) do
      local ids = {}
      for _, rank in ipairs(ranks) do
        if ids[rank[1]] then
          actual[name] = true
        end
        ids[rank[1]] = true
      end
    end
    assert.same(expected, actual)
  end)
end)

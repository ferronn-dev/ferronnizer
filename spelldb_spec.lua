describe('spell db', function()
  it('knows about all spell actions', function()
    local knownBad = {
      ['!Auto Shot'] = true,
      ['!Shoot'] = true,
      ['Cold Snap'] = true,
      ['Desperate Prayer'] = true,
      ['Divine Intervention'] = true,
      ['Divine Favor'] = true,
      ['Evocation'] = true,
      ['Inner Focus'] = true,
      ['Lay on Hands'] = true,
      ['Pick Pocket'] = true,
      ['Stealth'] = true,
    }
    if wow.env.WOW_PROJECT_ID == 2 then
      knownBad.Fishing = true
    end
    local seenBad = {}
    for fullname, spec in pairs(wow.addon.ClassActionSpecs) do
      for _, actions in ipairs(spec) do
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
    end
    assert.same(knownBad, seenBad)
  end)
  it('does not duplicate spell ids', function()
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
    assert.same({}, actual)
  end)
end)

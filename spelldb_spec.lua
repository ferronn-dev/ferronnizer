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
end)

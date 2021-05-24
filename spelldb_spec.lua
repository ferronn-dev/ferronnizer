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
    if wow.env.WOW_PROJECT_ID == wow.env.WOW_PROJECT_BURNING_CRUSADE_CLASSIC then
      -- TODO Detect Magic doesn't actually exist in BCC
      knownBad['Detect Magic'] = true
    end
    local seenBad = {}
    for toon in require('lfs').dir('toons') do
      local name, realm = string.match(toon, '^(%a+)-(%a+).lua$')
      if name then
        local fullname = name .. '-' .. realm
        for _, action in pairs(wow.addon.Characters[fullname]) do
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
end)

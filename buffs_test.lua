local T = require('testing')

local function assertCastSpell(state, spell)
  state.frames['PartyBuffButton']:Click()
  local macro = '/stand\n/cancelform\n/cast [@player]spell'..spell
  T.assertEquals({{ macro = macro }}, state.commands)
end

T.RunTests({
  function(state)
    local button = state.frames['PartyBuffButton']
    button:Click()
    T.assertEquals('macro', button:GetAttribute('type'))
    T.assertEquals('', button:GetAttribute('macrotext'))
    T.assertEquals({{ macro = '/shrug [@none]' }}, state.commands)
  end,
  function(state)
    state.inCombat = true
    state.frames['PartyBuffButton']:Click()
    T.assertEquals({{ macro = '' }}, state.commands)
  end,
  function(state)
    state.knownSpells = {2580}
    assertCastSpell(state, 2580)
  end,
  function(state)
    state.knownSpells = {10157}
    state.frames['PartyBuffButton']:Click()
    T.assertEquals({{ macro = '/shrug [@none]' }}, state.commands)
  end,
  function(state)
    state.knownSpells = {10157, 10156}
    assertCastSpell(state, 10156)
  end,
  function(state)
    state.knownSpells = {10054}
    assertCastSpell(state, 10054)
  end,
  function(state)
    state.knownSpells = {10219}
    assertCastSpell(state, 10219)
  end,
  function(state)
    state.knownSpells = {10219, 6117}
    assertCastSpell(state, 6117)
  end,
  function(state)
    state.player.level = 60
    state.knownSpells = {10157, 23028}
    assertCastSpell(state, 10157)
  end,
  function(state)
    state.player.level = 60
    state.inventory[17020] = 20
    state.knownSpells = {10157, 23028}
    assertCastSpell(state, 23028)
  end,
  function(state)
    state.player.level = 60
    state.buffs = {10157}
    state.knownSpells = {10157, 10156}
    state.frames['PartyBuffButton']:Click()
    T.assertEquals({{ macro = '/shrug [@none]' }}, state.commands)
  end,
})

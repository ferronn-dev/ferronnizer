describe('PartyBuffButton', function()
  local assertCastSpell = function(spell)
    wow.env.mooPartyBuffButton:Click()
    local macro = '/stand\n/cancelform\n/cast [@player]spell'..spell
    assert.same({{ macro = macro }}, wow.state.commands)
  end

  it('shrugs by default', function()
    local button = wow.env.mooPartyBuffButton
    button:Click()
    assert.same('macro', button:GetAttribute('type'))
    assert.same('', button:GetAttribute('macrotext'))
    assert.same({{ macro = '/shrug [@none]' }}, wow.state.commands)
  end)

  it('issues no commands in combat', function()
    wow.state:EnterCombat()
    wow.env.mooPartyBuffButton:Click()
    assert.same({{ macro = '' }}, wow.state.commands)
  end)

  it('can cast tracking spells', function()
    wow.state.knownSpells = {2580}
    assertCastSpell(2580)
  end)

  it('shrugs if we know spells but cannot cast them', function()
    wow.state.knownSpells = {10157}
    wow.env.mooPartyBuffButton:Click()
    assert.same({{ macro = '/shrug [@none]' }}, wow.state.commands)
  end)

  it('casts first available rank', function()
    wow.state.knownSpells = {10157, 10156}
    assertCastSpell(10156)
  end)

  it('can conjure managems', function()
    wow.state.knownSpells = {10054}
    assertCastSpell(10054)
  end)

  it('can cast ice armor', function()
    wow.state.knownSpells = {10219}
    assertCastSpell(10219)
  end)

  it('prefers mage armor over ice armor', function()
    wow.state.knownSpells = {10219, 6117}
    assertCastSpell(6117)
  end)

  it('skips group spells when reagents are missing', function()
    wow.state.inGroup = true
    wow.state.player.level = 60
    wow.state.knownSpells = {10157, 23028}
    assertCastSpell(10157)
  end)

  it('skips group spells when not in group', function()
    wow.state.player.level = 60
    wow.state.inventory[17020] = 20
    wow.state.knownSpells = {10157, 23028}
    assertCastSpell(10157)
  end)

  it('prefers to cast group spells in group as long as reagents are available', function()
    wow.state.player.level = 60
    wow.state.inGroup = true
    wow.state.inventory[17020] = 20
    wow.state.knownSpells = {10157, 23028}
    assertCastSpell(23028)
  end)

  it('does not cast lower ranks if the higher rank is already present', function()
    wow.state.player.level = 60
    wow.state.buffs = {10157}
    wow.state.knownSpells = {10157, 10156}
    wow.env.mooPartyBuffButton:Click()
    assert.same({{ macro = '/shrug [@none]' }}, wow.state.commands)
  end)

  it('casts solo spells', function()
    wow.state.knownSpells = {604}
    assertCastSpell(604)
  end)

  it('does not cast solo spells in group', function()
    wow.state.knownSpells = {604}
    wow.state.inGroup = true
    wow.env.mooPartyBuffButton:Click()
    assert.same({{ macro = '/shrug [@none]' }}, wow.state.commands)
  end)
end)

describe('buff button', function()
  it('works', function()
    wow.state.knownSpells = {10156}
    wow.env.mooBuffButton:Click()
    local macro = '/stand\n/cancelform\n/cast [@player]spell10156'
    assert.same({{ macro = macro }}, wow.state.commands)
    assert.same('Casting spell10156 on Kewhand.\n', wow.state.printed)
  end)
end)

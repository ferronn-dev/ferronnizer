describe('BuffButton', function()
  local function assertCastSpell(spell)
    wow.env.mooBuffButton:Click()
    local macro = '/stand\n/cancelform\n/cast [@player]spell' .. spell
    assert.same('Casting spell' .. spell .. ' on Kewhand.\n', wow.state.printed)
    assert.same({ { macro = macro } }, wow.state.commands)
  end

  local function assertNoCast()
    wow.env.mooBuffButton:Click()
    assert.same('', wow.state.printed)
    assert.same({ { macro = '' } }, wow.state.commands)
  end

  it('does nothing by default', function()
    local button = wow.env.mooBuffButton
    assertNoCast()
    assert.same('macro', button:GetAttribute('type'))
    assert.same('', button:GetAttribute('macrotext'))
  end)

  it('issues no commands in combat', function()
    wow.state:EnterCombat()
    assertNoCast()
  end)

  it('can cast tracking spells', function()
    if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
      wow.state.knownSpells = { 2580 }
      assertCastSpell(2580)
    end
  end)

  it('does nothing if we know spells but cannot cast them', function()
    wow.state.knownSpells = { 10157 }
    assertNoCast()
  end)

  it('casts first available rank', function()
    wow.state.knownSpells = { 10157, 10156 }
    assertCastSpell(10156)
  end)

  it('can conjure managems', function()
    wow.state.knownSpells = { 10054 }
    assertCastSpell(10054)
  end)

  it('can conjure food', function()
    wow.state.knownSpells = { 587 }
    assertCastSpell(587)
  end)

  it('can conjure water', function()
    wow.state.knownSpells = { 5504 }
    assertCastSpell(5504)
  end)

  it('can cast ice armor', function()
    wow.state.knownSpells = { 10219 }
    assertCastSpell(10219)
  end)

  it('prefers mage armor over ice armor', function()
    wow.state.knownSpells = { 10219, 6117 }
    assertCastSpell(6117)
  end)

  it('skips group spells when reagents are missing', function()
    wow.state.inGroup = true
    wow.state.player.level = 60
    wow.state.knownSpells = { 10157, 23028 }
    assertCastSpell(10157)
  end)

  it('skips group spells when not in group', function()
    wow.state.player.level = 60
    wow.state.inventory[17020] = 20
    wow.state.knownSpells = { 10157, 23028 }
    assertCastSpell(10157)
  end)

  it('prefers to cast group spells in group as long as reagents are available', function()
    wow.state.player.level = 60
    wow.state.inGroup = true
    wow.state.inventory[17020] = 20
    wow.state.knownSpells = { 10157, 23028 }
    assertCastSpell(23028)
  end)

  it('does not cast lower ranks if the higher rank is already present', function()
    wow.state.player.level = 60
    wow.state.buffs = { 10157 }
    wow.state.knownSpells = { 10157, 10156 }
    assertNoCast()
  end)

  it('casts solo spells', function()
    wow.state.knownSpells = { 604 }
    assertCastSpell(604)
  end)

  it('does not cast solo spells in group', function()
    wow.state.knownSpells = { 604 }
    wow.state.inGroup = true
    assertNoCast()
  end)

  it('casts when player class is in class list', function()
    wow.state.player.class = 2
    wow.state.knownSpells = { 14752 }
    assertCastSpell(14752)
  end)

  it('does not cast when player class is not in class list', function()
    wow.state.player.class = 1
    wow.state.knownSpells = { 14752 }
    assertNoCast()
  end)
end)

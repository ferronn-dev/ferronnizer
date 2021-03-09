describe('PartyBuffButton', function()
  local state
  before_each(function()
    state = require('addonloader')()
  end)

  local assertCastSpell = function(spell)
    state.frames['PartyBuffButton']:Click()
    local macro = '/stand\n/cancelform\n/cast [@player]spell'..spell
    assert.same({{ macro = macro }}, state.commands)
  end

  it('shrugs by default', function()
    local button = state.frames['PartyBuffButton']
    button:Click()
    assert.same('macro', button:GetAttribute('type'))
    assert.same('', button:GetAttribute('macrotext'))
    assert.same({{ macro = '/shrug [@none]' }}, state.commands)
  end)

  it('issues no commands in combat', function()
    state:EnterCombat()
    state.frames['PartyBuffButton']:Click()
    assert.same({{ macro = '' }}, state.commands)
  end)

  it('can cast tracking spells', function()
    state.knownSpells = {2580}
    assertCastSpell(2580)
  end)

  it('shrugs if we know spells but cannot cast them', function()
    state.knownSpells = {10157}
    state.frames['PartyBuffButton']:Click()
    assert.same({{ macro = '/shrug [@none]' }}, state.commands)
  end)

  it('casts first available rank', function()
    state.knownSpells = {10157, 10156}
    assertCastSpell(10156)
  end)

  it('can conjure managems', function()
    state.knownSpells = {10054}
    assertCastSpell(10054)
  end)

  it('can cast ice armor', function()
    state.knownSpells = {10219}
    assertCastSpell(10219)
  end)

  it('prefers mage armor over ice armor', function()
    state.knownSpells = {10219, 6117}
    assertCastSpell(6117)
  end)

  it('skips group spells when reagents are missing', function()
    state.player.level = 60
    state.knownSpells = {10157, 23028}
    assertCastSpell(10157)
  end)

  it('prefers to cast group spells as long as reagents are available', function()
    state.player.level = 60
    state.inventory[17020] = 20
    state.knownSpells = {10157, 23028}
    assertCastSpell(23028)
  end)

  it('does not cast lower ranks if the higher rank is already present', function()
    state.player.level = 60
    state.buffs = {10157}
    state.knownSpells = {10157, 10156}
    state.frames['PartyBuffButton']:Click()
    assert.same({{ macro = '/shrug [@none]' }}, state.commands)
  end)
end)

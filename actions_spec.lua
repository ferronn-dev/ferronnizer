local lfs = require('lfs')
describe('Actions', function()
  local function init(wow, actions)
    wow.addon.Characters['Moo-Cow'] = actions
    wow.state.player.name = 'Moo'
    wow.state.realm = 'Cow'
    wow.state:SendEvent('PLAYER_LOGIN')
  end
  it('makes a button', function()
    wow.state.knownSpells = {23456}
    init(wow, {
      [1] = {
        mouseover = true,
        rank = 5,
        spell = 'Greater Heal',
      },
    })
    wow.env.mooActionButton1:Click()
    local macro = (
        '/dismount\n/stand\n'..
        '/cast [@mouseover,help,nodead][] Greater Heal(Rank 5)')
    assert.same({{ macro = macro }}, wow.state.commands)
  end)
  it('drinks', function()
    init(wow, {
      [46] = { drink = true },
    })
    assert.same('/use ', wow.env.mooActionButton46:GetAttribute('macrotext'):sub(1, 5))
  end)
  it('makes the right amount of buttons', function()
    init(wow, {})
    assert.Not.Nil(wow.env.mooActionButton1)
    assert.Not.Nil(wow.env.mooActionButton48)
    assert.Nil(wow.env.mooActionButton49)
  end)
  it('invokes macros on click', function()
    init(wow, {
      [34] = { buff = true },
    })
    wow.env.mooActionButton34:Click()
    local macro = '/click mooBuffButton'
    assert.same({{ macro = macro }}, wow.state.commands)
  end)
  it('does not crash on events', function()
    wow.state.player.name = 'Shydove'
    wow.state.realm = 'Westfall'
    wow.state:SendEvent('PLAYER_LOGIN')
    wow.state:SendEvent('BAG_UPDATE_DELAYED')
    wow.state:SendEvent('UPDATE_BINDINGS')
    wow.state:SendEvent('SPELL_UPDATE_COOLDOWN')
    wow.state:SendEvent('PLAYER_EQUIPMENT_CHANGED')
    wow.state:EnterCombat()
    wow.state:SendEvent('BAG_UPDATE_DELAYED')
    wow.state:LeaveCombat()
    wow.state:SendEvent('BAG_UPDATE_DELAYED')
  end)
  it('obeys stopcasting', function()
    wow.state.knownSpells = {23456}
    init(wow, {
      [41] = {
        mouseover = true,
        stopcasting = true,
        spell = 'Lay on Hands',
      },
    })
    wow.env.mooActionButton41:Click()
    local macro = (
        '/dismount\n/stand\n/stopcasting\n'..
        '/cast [@mouseover,help,nodead][] Lay on Hands')
    assert.same({{ macro = macro }}, wow.state.commands)
  end)
  for toon in lfs.dir('toons') do
    local name, realm = string.match(toon, '^(%a+)-(%a+).lua$')
    if name then
      it('can initialize ' .. toon, function()
        wow.state.player.name = name
        wow.state.realm = realm
        wow.state:SendEvent('PLAYER_LOGIN')
      end)
    end
  end
  it('has non-combat macrotexts that are not too long', function()
    wow.state.player.name = 'Shydove'
    wow.state.realm = 'Westfall'
    wow.state:SendEvent('PLAYER_LOGIN')
    for i = 1, 48 do
      local t = wow.env['mooActionButton' .. i]:GetAttribute('macrotext')
      assert.True(not t or t:len() < 1024, i)
    end
  end)
  it('has combat macrotexts that are not too long', function()
    wow.state.player.name = 'Shydove'
    wow.state.realm = 'Westfall'
    wow.state:SendEvent('PLAYER_LOGIN')
    wow.state:EnterCombat()
    for i = 1, 48 do
      local t = wow.env['mooActionButton' .. i]:GetAttribute('macrotext')
      assert.True(not t or t:len() < 1024, i)
    end
  end)
  it('hides buttons with no actions', function()
    init(wow, {
      [43] = { mount = true },
    })
    assert.False(wow.env.mooActionButton43:IsShown())
    assert.False(wow.env.mooActionButton44:IsShown())
  end)
  it('shows mount button when a mount is available', function()
    wow.state.inventory[5663] = 1
    init(wow, {
      [43] = { mount = true },
    })
    assert.True(wow.env.mooActionButton43:IsShown())
    assert.False(wow.env.mooActionButton44:IsShown())
  end)
  it('does not crash OnUpdate', function()
    wow.state.player.name = 'Shydove'
    wow.state.realm = 'Westfall'
    wow.state:SendEvent('PLAYER_LOGIN')
    wow.state:TickUpdate(1)
  end)
  it('manages button state machine for spells', function()
    init(wow, {
      [1] = { spell = 'Greater Heal' },
    })
    assert.False(wow.env.mooActionButton1:IsShown())
    wow.state:EnterCombat()
    assert.False(wow.env.mooActionButton1:IsShown())
    wow.state.knownSpells = {23456}
    wow.state:SendEvent('SPELLS_CHANGED')
    assert.False(wow.env.mooActionButton1:IsShown())
    wow.state:LeaveCombat()
    assert.True(wow.env.mooActionButton1:IsShown())
  end)
end)

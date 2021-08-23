local lfs = require('lfs')
describe('Actions', function()

  local function init(wow, actions)
    wow.addon.Characters['Moo-Cow'] = actions
    wow.state.player.name = 'Moo'
    wow.state.realm = 'Cow'
    wow.state:SendEvent('PLAYER_LOGIN')
    wow.state:SendEvent('PLAYER_ENTERING_WORLD')
  end

  local everything = {
    { action = 3 },
    { buff = true },
    { drink = true },
    { eat = true },
    { invslot = 13 },
    { macro = '/lol' },
    { mount = true },
    { page = {} },
    { petaction = 7 },
    { spell = 'Cooking' },
    { stopcasting = true },
  }

  it('makes a button', function()
    wow.state.knownSpells = {23456}
    init(wow, {
      [1] = {
        mouseover = true,
        rank = 5,
        spell = 'Greater Heal',
      },
    })
    wow.env.mooActionIconButton1:Click()
    local macro = (
        '/dismount\n/stand\n'..
        '/cast [@mouseover,help,nodead][] Greater Heal(Rank 5)')
    assert.same({{ macro = macro }}, wow.state.commands)
  end)

  it('drinks', function()
    init(wow, {
      [46] = { drink = true },
    })
    assert.same('/use ', wow.env.mooActionIconButton46:GetAttribute('macrotext'):sub(1, 5))
  end)

  it('makes the right amount of buttons', function()
    init(wow, {})
    assert.Not.Nil(wow.env.mooActionIconButton1)
    assert.Not.Nil(wow.env.mooActionIconButton48)
    assert.Nil(wow.env.mooActionIconButton49)
  end)

  it('invokes macros on click', function()
    init(wow, {
      [34] = { buff = true },
    })
    wow.env.mooActionIconButton34:Click()
    local macro = '/click mooBuffButton'
    assert.same({{ macro = macro }}, wow.state.commands)
  end)

  it('does not crash on events', function()
    init(wow, everything)
    wow.state:SendEvent('PLAYER_LOGIN')
    wow.state:SendEvent('PLAYER_ENTERING_WORLD')
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
    wow.env.mooActionIconButton41:Click()
    local macro = (
        '/dismount\n/stand\n/stopcasting\n'..
        '/cast [@mouseover,help,nodead][] Lay on Hands')
    assert.same({{ macro = macro }}, wow.state.commands)
  end)

  local toonsInitialized = 0
  for toon in lfs.dir('toons/Vanilla') do
    local name, realm = string.match(toon, '^(%a+)-(%a+).lua$')
    if name then
      toonsInitialized = toonsInitialized + 1
      it('can initialize ' .. toon, function()
        wow.state.player.name = name
        wow.state.realm = realm
        wow.state:SendEvent('PLAYER_LOGIN')
        wow.state:SendEvent('PLAYER_ENTERING_WORLD')
        assert.same('fraction', wow.env.mooActionButtonHeader:GetAttribute('fractionpage'))
      end)
    end
  end

  it('initializes at least one toon', function()
    assert.True(toonsInitialized > 0)
  end)

  it('has non-combat macrotexts that are not too long', function()
    init(wow, everything)
    for i = 1, 48 do
      local t = wow.env['mooActionIconButton' .. i]:GetAttribute('macrotext')
      assert.True(not t or t:len() < 1024, i)
    end
  end)

  it('has combat macrotexts that are not too long', function()
    init(wow, everything)
    wow.state:EnterCombat()
    for i = 1, 48 do
      local t = wow.env['mooActionIconButton' .. i]:GetAttribute('macrotext')
      assert.True(not t or t:len() < 1024, i)
    end
  end)

  it('hides buttons with no actions', function()
    init(wow, {
      [43] = { mount = true },
    })
    assert.False(wow.env.mooActionIconButton43:IsShown())
    assert.False(wow.env.mooActionIconButton44:IsShown())
  end)

  it('shows mount button when a mount is available', function()
    wow.state.inventory[5663] = 1
    init(wow, {
      [43] = { mount = true },
    })
    assert.True(wow.env.mooActionIconButton43:IsShown())
    assert.False(wow.env.mooActionIconButton44:IsShown())
  end)

  it('does not crash OnUpdate', function()
    init(wow, everything)
    wow.state:TickUpdate(1)
  end)

  it('manages button state machine for spells', function()
    init(wow, {
      [1] = { spell = 'Greater Heal' },
    })
    assert.False(wow.env.mooActionIconButton1:IsShown())
    wow.state:EnterCombat()
    assert.False(wow.env.mooActionIconButton1:IsShown())
    wow.state.knownSpells = {23456}
    wow.state:SendEvent('SPELLS_CHANGED')
    assert.False(wow.env.mooActionIconButton1:IsShown())
    wow.state:LeaveCombat()
    assert.True(wow.env.mooActionIconButton1:IsShown())
  end)

  it('changes pages', function()
    init(wow, {
      [1] = {
        page = {
          [2] = { macro = '/lol' },
        },
      },
    })
    assert.True(wow.env.mooActionIconButton1:IsShown())
    assert.False(wow.env.mooActionIconButton2:IsShown())
    wow.env.mooActionIconButton1:Click()
    assert.False(wow.env.mooActionIconButton1:IsShown())
    assert.True(wow.env.mooActionIconButton2:IsShown())
    wow.env.mooActionIconButton2:Click()
    assert.True(wow.env.mooActionIconButton1:IsShown())
    assert.False(wow.env.mooActionIconButton2:IsShown())
    assert.same({
      { macro = '#page:fraction1x' },
      { macro = '/lol' },
    }, wow.state.commands)
  end)

  it('sets correct attributes on actions', function()
    wow.state.actions[42] = true
    init(wow, { { action = 42 } })
    local button = wow.env.mooActionIconButton1
    assert.same('action', button:GetAttribute('type'))
    assert.same(42, button:GetAttribute('action'))
  end)

  it('sets correct attributes on petactions', function()
    wow.state.petactions[2] = { nil, 'texture', false }
    init(wow, { { petaction = 2 } })
    local button = wow.env.mooActionIconButton1
    assert.same('pet', button:GetAttribute('type'))
    assert.same(2, button:GetAttribute('action'))
  end)

  it('sets button text', function()
    init(wow, {{ macro = '/lol', actionText = 'Laugh' }})
    assert.same('Laugh', wow.env.mooActionIconButton1.Name:GetText())
  end)

  it('sets button text through paging', function()
    init(wow, {{
      actionText = 'Parent',
      page = {{ actionText = 'Child', macro = '/lol' }},
    }})
    local button = wow.env.mooActionIconButton1
    assert.same('Parent', button.Name:GetText())
    button:Click()
    assert.same('Child', button.Name:GetText())
    button:Click()
    assert.same('Parent', button.Name:GetText())
  end)

  it('changes inventory counts', function()
    init(wow, {{ buff = true, reagent = 12345 }})
    local button = wow.env.mooActionIconButton1
    wow.state.inventory[12345] = 7
    wow.state:SendEvent('BAG_UPDATE_DELAYED')
    assert.same('7', button.Count:GetText())
    wow.state.inventory[12345] = 5
    wow.state:SendEvent('BAG_UPDATE_DELAYED')
    assert.same('5', button.Count:GetText())
  end)

  it('does not overwrite button count if action page is not current', function()
    init(wow, {
      [1] = { buff = true, reagent = 12345 },
      [2] = {
        page = {
          [1] = { buff = true },
        },
      }
    })
    local buffButton = wow.env.mooActionIconButton1
    local pageButton = wow.env.mooActionIconButton2
    wow.state.inventory[12345] = 7
    wow.state:SendEvent('BAG_UPDATE_DELAYED')
    assert.same('7', buffButton.Count:GetText())
    pageButton:Click()
    assert.same('', buffButton.Count:GetText())
    wow.state.inventory[12345] = 5
    wow.state:SendEvent('BAG_UPDATE_DELAYED')
    assert.same('', buffButton.Count:GetText())
    buffButton:Click()
    assert.same('5', buffButton.Count:GetText())
  end)

  it('creates switcher buttons', function()
    init(wow, everything)
    assert.Not.Nil(wow.env.mooActionButtonAction1Switcher)
    assert.Not.Nil(wow.env.mooActionButtonAction2Switcher)
    assert.Not.Nil(wow.env.mooActionButtonEmoteSwitcher)
    assert.Not.Nil(wow.env.mooActionButtonFractionSwitcher)
    assert.Not.Nil(wow.env.mooActionButtonFraction8xSwitcher)
    assert.Not.Nil(wow.env.mooActionButtonPetSwitcher)
    assert.Not.Nil(wow.env.mooActionButtonProfessionSwitcher)
  end)

  it('honors class action specs', function()
    wow.addon.ClassActionSpecs['PALADIN'] = { [37] = { buff = true } }
    wow.state:SendEvent('PLAYER_LOGIN')
    wow.state:SendEvent('PLAYER_ENTERING_WORLD')
    assert.True(wow.env.mooActionIconButton37:IsShown())
  end)
end)

describe('MountButton', function()
  local state
  before_each(function()
    state = require('addonloader')()
  end)

  it('shrugs by default and restores attribute to dismount', function()
    local button = state.frames['MountButton']
    button:Click()
    assert.same('macro', button:GetAttribute('type'))
    assert.same('/dismount', button:GetAttribute('macrotext'))
    assert.same({{ macro = '/shrug [@none]' }}, state.commands)
  end)

  it('dismounts in combat', function()
    state:EnterCombat()
    state.frames['MountButton']:Click()
    assert.same({{ macro = '/dismount' }}, state.commands)
  end)

  it('dismounts when mounted', function()
    state.isMounted = true
    state.frames['MountButton']:Click()
    assert.same({{ macro = '/dismount' }}, state.commands)
  end)

  it('casts mount spells if available', function()
    state.knownSpells = {13819}
    state.frames['MountButton']:Click()
    assert.same({{ macro = '/stand\n/cancelform\n/cast spell13819' }}, state.commands)
  end)

  it('uses mount items if available', function()
    state.inventory = { [8631] = 1 }
    state.frames['MountButton']:Click()
    assert.same({{ macro = '/stand\n/cancelform\n/use item:8631' }}, state.commands)
  end)
end)

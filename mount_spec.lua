describe('MountButton', function()
  it('shrugs by default and restores attribute to dismount', function()
    local button = wow.env.mooMountButton
    button:Click()
    assert.same('macro', button:GetAttribute('type'))
    assert.same('/dismount', button:GetAttribute('macrotext'))
    assert.same({{ macro = '/shrug [@none]' }}, wow.state.commands)
  end)

  it('dismounts in combat', function()
    wow.state:EnterCombat()
    wow.env.mooMountButton:Click()
    assert.same({{ macro = '/dismount' }}, wow.state.commands)
  end)

  it('dismounts when mounted', function()
    wow.state.isMounted = true
    wow.env.mooMountButton:Click()
    assert.same({{ macro = '/dismount' }}, wow.state.commands)
  end)

  it('casts mount spells if available', function()
    wow.state.knownSpells = {13819}
    wow.env.mooMountButton:Click()
    assert.same({{ macro = '/stand\n/cancelform\n/cast spell13819' }}, wow.state.commands)
  end)

  it('uses mount items if available', function()
    wow.state.inventory = { [8631] = 1 }
    wow.env.mooMountButton:Click()
    assert.same({{ macro = '/stand\n/cancelform\n/use item:8631' }}, wow.state.commands)
  end)
end)

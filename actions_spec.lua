describe('Actions', function()
  it('makes a button', function()
    wow.state.player.name = 'Shydove'
    wow.state.realm = 'Westfall'
    wow.state:SendEvent('PLAYER_LOGIN')
    wow.env.mooActionButton1:Click()
    local macro = (
        '/dismount\n/stand\n'..
        '/cast [@mouseover,help,nodead][] Greater Heal(Rank 5)')
    assert.same({{ macro = macro }}, wow.state.commands)
  end)
  it('toggles on click', function()
    wow.state:SendEvent('PLAYER_LOGIN')
    wow.env.mooToggleActionDragButton:Click()
    wow.env.mooToggleActionDragButton:Click()
  end)
  it('drinks', function()
    wow.state.player.name = 'Shydove'
    wow.state.realm = 'Westfall'
    wow.state.inventory[8079] = 2
    wow.state:SendEvent('PLAYER_LOGIN')
    wow.env.mooActionButton46:Click()
    assert.same({{ macro = '/use item:8079' }}, wow.state.commands)
  end)
  it('makes the right amount of buttons', function()
    wow.state:SendEvent('PLAYER_LOGIN')
    assert.Not.Nil(wow.env.mooActionButton1)
    assert.Not.Nil(wow.env.mooActionButton48)
    assert.Nil(wow.env.mooActionButton49)
  end)
  it('invokes macros on click', function()
    wow.state.player.name = 'Shydove'
    wow.state.realm = 'Westfall'
    wow.state:SendEvent('PLAYER_LOGIN')
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
  end)
end)

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
    wow.state:SendEvent('PLAYER_LOGIN')
    wow.env.mooActionButton46:Click()
    local macro = '/click mooDrinkButton'
    assert.same({{ macro = macro }}, wow.state.commands)
  end)
  it('makes the right amount of buttons', function()
    wow.state:SendEvent('PLAYER_LOGIN')
    assert.Not.Nil(wow.env.mooActionButton1)
    assert.Not.Nil(wow.env.mooActionButton48)
    assert.Nil(wow.env.mooActionButton49)
  end)
end)

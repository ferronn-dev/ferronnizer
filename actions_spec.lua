describe('Actions', function()
  it('makes a button', function()
    wow.state.player.name = 'Shydove'
    wow.state.realm = 'Westfall'
    wow.state:SendEvent('PLAYER_LOGIN')
    local button = wow.state.frames['mooActionButton1']
    button:Click()
    local macro = (
        '/dismount\n/stand\n'..
        '/cast [@mouseover,help,nodead][] Greater Heal(Rank 4)')
    assert.same({{ macro = macro }}, wow.state.commands)
  end)
  it('toggles on click', function()
    wow.state:SendEvent('PLAYER_LOGIN')
    wow.env.ToggleActionDragButton:Click()
    wow.env.ToggleActionDragButton:Click()
  end)
  it('drinks', function()
    wow.state.player.name = 'Shydove'
    wow.state.realm = 'Westfall'
    wow.state:SendEvent('PLAYER_LOGIN')
    wow.state.frames['mooActionButton46']:Click()
    local macro = '/click DrinkButton'
    assert.same({{ macro = macro }}, wow.state.commands)
  end)
end)

describe('Actions', function()
  it('makes a button', function()
    wow.state:SendEvent('PLAYER_LOGIN')
    local button = wow.state.frames['mooActionButton1']
    button:Click()
  end)
  it('toggles on click', function()
    wow.state:SendEvent('PLAYER_LOGIN')
    wow.env.ToggleActionDragButton:Click()
    wow.env.ToggleActionDragButton:Click()
  end)
end)

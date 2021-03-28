describe('Actions', function()
  it('makes a button', function()
    wow.state:SendEvent('PLAYER_LOGIN')
    local button = wow.state.frames['mooActionButton1']
    button:Click()
  end)
end)

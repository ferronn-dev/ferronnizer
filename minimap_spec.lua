describe('minimap module', function()
  it('loads', function()
    wow.state:SendEvent('PLAYER_LOGIN')
    wow.state:SendEvent('PLAYER_ENTERING_WORLD')
  end)
end)

describe('chatframe', function()
  it('does not crash on login', function()
    local state = require('addonloader')()
    state:SendEvent('PLAYER_LOGIN')
  end)
end)

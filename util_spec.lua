describe('utility functions', function()
  describe('time conversions', function()
    local state, _, addon = require('addonloader')()
    state.localTime = 100
    state.serverTime = 200

    it('converts back and forth', function()
      assert.same(180, addon.LocalToServer(80))
      assert.same(80, addon.ServerToLocal(180))
    end)

    it('clamps to zero', function()
      assert.same(0, addon.LocalToServer(0))
      assert.same(0, addon.ServerToLocal(0))
    end)
  end)
end)

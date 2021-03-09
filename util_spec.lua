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

  describe('non-combat eventer', function()
    local state, addon, timesCalled
    before_each(function()
      local _
      state, _, addon = require('addonloader')()
      timesCalled = 0
      addon.NonCombatEventer({
        SKILL_LINES_CHANGED = function()
          timesCalled = timesCalled + 1
        end,
      })
      assert.same(0, timesCalled)
    end)

    it('works like a normal eventer outside of combat', function()
      state:SendEvent('SKILL_LINES_CHANGED')
      assert.same(1, timesCalled)
    end)

    it('waits till after combat to fire', function()
      state.inCombat = true
      state:SendEvent('SKILL_LINES_CHANGED')
      assert.same(0, timesCalled)
      state:SendEvent('SKILL_LINES_CHANGED')
      assert.same(0, timesCalled)
      state.inCombat = false
      state:SendEvent('PLAYER_REGEN_ENABLED')
      assert.same(2, timesCalled)
    end)
  end)
end)

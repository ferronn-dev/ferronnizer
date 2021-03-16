describe('utility functions', function()
  describe('time conversions', function()
    it('converts back and forth', function()
      wow.state.localTime = 100
      wow.state.serverTime = 200
      assert.same(180, wow.addon.LocalToServer(80))
      assert.same(80, wow.addon.ServerToLocal(180))
    end)

    it('clamps to zero', function()
      wow.state.localTime = 100
      wow.state.serverTime = 200
      assert.same(0, wow.addon.LocalToServer(0))
      assert.same(0, wow.addon.ServerToLocal(0))
    end)
  end)

  describe('non-combat eventer', function()
    local function eventer(wow)
      local x = { timesCalled = 0 }
      wow.addon.NonCombatEventer({
        SKILL_LINES_CHANGED = function()
          x.timesCalled = x.timesCalled + 1
        end,
      })
      assert.same(0, x.timesCalled)
      return x
    end

    it('works like a normal eventer outside of combat', function()
      local x = eventer(wow)
      wow.state:SendEvent('SKILL_LINES_CHANGED')
      assert.same(1, x.timesCalled)
    end)

    it('waits till after combat to fire', function()
      local x = eventer(wow)
      wow.state:EnterCombat()
      wow.state:SendEvent('SKILL_LINES_CHANGED')
      assert.same(0, x.timesCalled)
      wow.state:SendEvent('SKILL_LINES_CHANGED')
      assert.same(0, x.timesCalled)
      wow.state:LeaveCombat()
      assert.same(2, x.timesCalled)
    end)
  end)
end)

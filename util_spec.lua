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
    local function eventer(wow, events)
      local counts = {}
      local handlers = {}
      for _, e in ipairs(events) do
        handlers[e] = function()
          counts[e] = (counts[e] or 0) + 1
        end
      end
      wow.addon.NonCombatEventer(handlers)
      assert.same({}, counts)
      return counts
    end

    it('works like a normal eventer outside of combat', function()
      local event = 'SKILL_LINES_CHANGED'
      local counts = eventer(wow, { event })
      wow.state:SendEvent(event)
      assert.same({ [event] = 1 }, counts)
    end)

    it('waits till after combat to fire', function()
      local event = 'SKILL_LINES_CHANGED'
      local counts = eventer(wow, { event })
      wow.state:EnterCombat()
      wow.state:SendEvent(event)
      assert.same({}, counts)
      wow.state:SendEvent(event)
      assert.same({}, counts)
      wow.state:LeaveCombat()
      assert.same({ [event] = 2 }, counts)
    end)

    it('supports PLAYER_REGEN_ENABLED', function()
      local event = 'PLAYER_REGEN_ENABLED'
      local counts = eventer(wow, { event })
      wow.state:SendEvent(event)
      assert.same({ [event] = 1 }, counts)
    end)
  end)

  describe('pre-click button', function()
    it('returns the button', function()
      local count = 0
      local button = wow.addon.PreClickButton('Foo', 'moo', function()
        count = count + 1
        return 'cow' .. count
      end)
      assert.equal(wow.env.mooFoo, button)
      button:Click()
      wow.state:EnterCombat()
      button:Click()
      wow.state:LeaveCombat()
      button:Click()
      assert.same({
        { macro = 'cow1' },
        { macro = 'moo' },
        { macro = 'cow2' },
      }, wow.state.commands)
    end)
  end)

  describe('updater', function()
    it('runs on first tick', function()
      local count = 0
      wow.addon.Updater(10000, function()
        count = count + 1
      end)
      wow.state:TickUpdate(1)
      assert.same(1, count)
    end)

    it('respects period', function()
      local count = 0
      wow.addon.Updater(10000, function()
        count = count + 1
      end)
      for _ = 1, 9999 do
        wow.state:TickUpdate(1)
      end
      assert.same(1, count)
      wow.state:TickUpdate(1)
      assert.same(1, count)
      wow.state:TickUpdate(1)
      assert.same(2, count)
    end)
  end)
end)

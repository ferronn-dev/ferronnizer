describe('utility functions', function()
  describe('pre-click button', function()
    it('returns the button', function()
      local count = 0
      local button = wow.addon.PreClickButton('Foo', function()
        count = count + 1
        return {
          macrotext = 'cow' .. count,
          type = 'macro',
        }
      end)
      assert.equal(wow.env.mooFoo, button)
      button:Click()
      wow.state:EnterCombat()
      button:Click()
      wow.state:LeaveCombat()
      button:Click()
      assert.same({
        { macro = 'cow1' },
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

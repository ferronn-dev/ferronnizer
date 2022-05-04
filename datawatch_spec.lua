local function newDataWatch()
  local data = {
    game_time = '4:20',
    units = {
      player = {
        level = 60,
        name = 'PlayerName',
      },
    },
  }
  local scripts = {}
  local globalEnv = {
    assert = assert,
    CreateFrame = function()
      return {
        RegisterEvent = function() end,
        SetScript = function(self, name, script)
          scripts[name] = function(...)
            return script(self, ...)
          end
        end,
      }
    end,
    GameTime_GetTime = function()
      return data.game_time
    end,
    ipairs = ipairs,
    pairs = pairs,
    table = table,
    tostring = tostring,
    UnitLevel = function(unit)
      return data.units[unit] and data.units[unit].level
    end,
    UnitName = function(unit)
      return data.units[unit] and data.units[unit].name
    end,
  }
  globalEnv._G = globalEnv
  local addonEnv = {}
  setfenv(loadfile('datawatch.lua'), globalEnv)('', addonEnv)
  return addonEnv.DataWatch, scripts.OnEvent, scripts.OnUpdate, data
end

describe('datawatch', function()
  it('works with no registrations', function()
    local _, _, onUpdate = newDataWatch()
    onUpdate()
    onUpdate()
  end)

  it('handles game_time', function()
    local game_time = 'foo'
    local watch, _, onUpdate, data = newDataWatch()
    watch('game_time', function(x)
      game_time = x
    end)
    assert.same('', game_time)
    onUpdate()
    assert.same('4:20', game_time)
    data.game_time = '5:35'
    onUpdate()
    assert.same('5:35', game_time)
  end)

  it('handles unit name', function()
    local watch, onEvent, _, data = newDataWatch()
    local player_name = 'foo'
    watch('player_name', function(x)
      player_name = x
    end)
    local focus_name = 'bar'
    watch('focus_name', function(x)
      focus_name = x
    end)
    assert.same('PlayerName', player_name)
    assert.Nil(focus_name)
    data.units.focus = { name = 'FocusName' }
    onEvent('UNIT_NAME_UPDATE', 'player')
    assert.same('PlayerName', player_name)
    assert.same('FocusName', focus_name)
    data.units.focus = nil
    onEvent('UNIT_NAME_UPDATE', 'target')
    assert.same('PlayerName', player_name)
    assert.Nil(focus_name)
  end)
end)

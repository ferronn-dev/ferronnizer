local function newDataWatch()
  local data = {
    game_time = '4:20',
  }
  local scripts = {}
  local globalEnv = {
    assert = assert,
    CreateFrame = function()
      return {
        RegisterEvent = function() end,
        SetScript = function(_, name, script)
          scripts[name] = script
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
    UnitLevel = function()
      return 60
    end,
    UnitName = function()
      return 'UnitName'
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
    assert.same('foo', game_time)
    onUpdate()
    assert.same('4:20', game_time)
    data.game_time = '5:35'
    onUpdate()
    assert.same('5:35', game_time)
  end)
end)

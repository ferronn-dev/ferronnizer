local function newDataWatch()
  local scripts = {}
  local globalEnv = {
    CreateFrame = function()
      return {
        RegisterEvent = function() end,
        SetScript = function(_, name, script)
          scripts[name] = script
        end,
      }
    end,
    GameTime_GetTime = function()
      return '4:20'
    end,
    ipairs = ipairs,
    pairs = pairs,
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
  return addonEnv.DataWatch, scripts.OnEvent, scripts.OnUpdate
end

describe('datawatch', function()
  it('works with no registrations', function()
    local _, _, onUpdate = newDataWatch()
    onUpdate()
    onUpdate()
  end)
end)

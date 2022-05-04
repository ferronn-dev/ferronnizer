local function newDataWatch()
  local globalEnv = {
    CreateFrame = function()
      return {
        RegisterEvent = function() end,
        SetScript = function() end,
      }
    end,
    pairs = pairs,
    UnitLevel = function()
      return 60
    end,
    UnitName = function()
      return 'UnitName'
    end,
  }
  local addonEnv = {}
  setfenv(loadfile('datawatch.lua'), globalEnv)('', addonEnv)
  return addonEnv.DataWatch
end

describe('datawatch', function()
  it('loads', function()
    newDataWatch()
  end)
end)

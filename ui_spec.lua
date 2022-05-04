local function loadUi()
  local globalEnv = {
    CreateFrame = function()
      return {
        CreateFontString = function()
          return {
            SetAllPoints = function() end,
            SetJustifyH = function() end,
            SetJustifyV = function() end,
          }
        end,
        SetPoint = function() end,
        SetSize = function() end,
      }
    end,
    FerronnizerRoot = {},
  }
  globalEnv._G = globalEnv
  local addonEnv = {
    DataWatch = function() end,
  }
  setfenv(loadfile('ui.lua'), globalEnv)('', addonEnv)
  return globalEnv.FerronnizerRoot
end

describe('ui', function()
  it('loads', function()
    local root = loadUi()
    assert.Not.Nil(root.Clock)
  end)
end)

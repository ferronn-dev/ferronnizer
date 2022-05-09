local function loadUi()
  local globalEnv
  globalEnv = {
    CreateFrame = function(_, name)
      local f = {
        CreateFontString = function()
          return {
            SetAllPoints = function() end,
            SetJustifyH = function() end,
            SetJustifyV = function() end,
          }
        end,
        CreateTexture = function()
          return {
            SetAllPoints = function() end,
            SetTexture = function() end,
          }
        end,
        Hide = function() end,
        RegisterEvent = function() end,
        RegisterForClicks = function() end,
        RegisterUnitEvent = function() end,
        SetAllPoints = function() end,
        SetAlpha = function() end,
        SetAttribute = function() end,
        SetPoint = function() end,
        SetScale = function() end,
        SetScript = function() end,
        SetSize = function() end,
        SetStatusBarTexture = function() end,
      }
      if name then
        globalEnv[name] = f
      end
      return f
    end,
    GetXPExhaustion = function() end,
    ipairs = ipairs,
    pairs = pairs,
    RegisterUnitWatch = function() end,
    table = table,
    type = type,
    unpack = unpack,
  }
  globalEnv._G = globalEnv
  local addonEnv = {
    DataWatch = function() end,
    Eventer = function() end,
  }
  setfenv(loadfile('ui.lua'), globalEnv)('', addonEnv)
  return globalEnv.FerronnizerRoot
end

describe('ui', function()
  it('loads', function()
    local root = loadUi()
    assert.Not.Nil(root.Clock)
    assert.Not.Nil(root.Hidden)
  end)
end)

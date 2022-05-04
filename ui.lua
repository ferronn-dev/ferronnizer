local _, G = ...

local root = _G.FerronnizerRoot

-- TODO move ui.xml back to lua
if root == nil then
  return
end

root.Clock = (function()
  local f = CreateFrame('Frame', root)
  f:SetPoint('TOPRIGHT')
  f:SetSize(30, 12)
  local fs = f:CreateFontString(nil, 'BACKGROUND', 'GameFontNormalSmall')
  fs:SetAllPoints()
  fs:SetJustifyH('RIGHT')
  fs:SetJustifyV('TOP')
  G.DataWatch('game_time', function(s)
    fs:SetText(s)
  end)
  f.Text = fs
  return f
end)()

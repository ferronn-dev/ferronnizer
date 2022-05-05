local _, G = ...

local root = _G.FerronnizerRoot

-- TODO move ui.xml back to lua
if root == nil then
  return
end

for _, v in pairs(root) do
  v.Name = (function()
    local f = CreateFrame('Frame', v)
    f:SetPoint('TOPLEFT')
    f:SetSize(160, 20)
    local fs = f:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
    fs:SetAllPoints()
    fs:SetJustifyH('CENTER')
    G.DataWatch(v.unit .. '_level', v.unit .. '_name', function(level, name)
      fs:SetText(level .. ' - ' .. name)
    end)
    f.Text = fs
    local t = f:CreateTexture()
    t:SetAllPoints()
    G.DataWatch(v.unit .. '_class', function(class)
      t:SetColorTexture(GetClassColor(class))
    end)
    f.Background = t
    return f
  end)()
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

root.Hidden = (function()
  local frames = {
    _G.BuffFrame,
    _G.CompactRaidFrameManager,
    _G.FocusFrame,
    _G.PartyMemberFrame1,
    _G.PartyMemberFrame2,
    _G.PartyMemberFrame3,
    _G.PartyMemberFrame4,
    _G.PlayerFrame,
    _G.TargetFrame,
    _G.TemporaryEnchantFrame,
  }
  local f = CreateFrame('Frame', root)
  f:Hide()
  for _, frame in pairs(frames) do
    frame:SetParent(f)
  end
  return f
end)()

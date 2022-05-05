local _, G = ...

local root = _G.FerronnizerRoot

-- TODO move ui.xml back to lua
if root == nil then
  return
end

for _, v in pairs(root) do
  if type(v) == 'table' then
    v.Name = (function()
      local f = CreateFrame('Frame', nil, v)
      f:SetPoint('TOPLEFT')
      f:SetSize(160, 20)
      local fs = f:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
      fs:SetAllPoints()
      fs:SetJustifyH('CENTER')
      G.DataWatch(v.unit .. '_level', v.unit .. '_name', function(level, name)
        fs:SetText(level .. ' - ' .. (name or ''))
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
    v.Health = (function()
      local f = CreateFrame('StatusBar', nil, v)
      f:SetPoint('TOPLEFT', 0, -20)
      f:SetSize(160, 20)
      f:SetStatusBarTexture('Interface\\Buttons\\WHITE8x8')
      G.DataWatch(v.unit .. '_class', function(class)
        f:SetStatusBarColor(GetClassColor(class))
      end)
      G.DataWatch(v.unit .. '_health', function(health)
        f:SetValue(health)
      end)
      G.DataWatch(v.unit .. '_max_health', function(maxHealth)
        f:SetMinMaxValues(0, maxHealth)
      end)
      local fs = f:CreateFontString(nil, 'ARTWORK', 'GameNormalNumberFont')
      fs:SetAllPoints()
      fs:SetJustifyH('CENTER')
      G.DataWatch(v.unit .. '_health', v.unit .. '_max_health', function(health, healthMax)
        fs:SetText(health .. ' / ' .. healthMax)
      end)
      f.Text = fs
      return f
    end)()
  end
end

root.Clock = (function()
  local f = CreateFrame('Frame', nil, root)
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
  local f = CreateFrame('Frame', nil, root)
  f:Hide()
  for _, frame in pairs(frames) do
    frame:SetParent(f)
  end
  return f
end)()

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
      local fs = f:CreateFontString(nil, 'ARTWORK', 'GameNormalNumberFont')
      fs:SetAllPoints()
      fs:SetJustifyH('CENTER')
      G.DataWatch(v.unit .. '_health', v.unit .. '_max_health', function(health, healthMax)
        f:SetMinMaxValues(0, healthMax)
        f:SetValue(health)
        fs:SetText(health .. ' / ' .. healthMax)
      end)
      f.Text = fs
      return f
    end)()
    v.Power = (function()
      local f = CreateFrame('StatusBar', nil, v)
      f:SetPoint('TOPLEFT', 0, -40)
      f:SetSize(160, 20)
      f:SetStatusBarTexture('Interface\\Buttons\\WHITE8x8')
      G.DataWatch(v.unit .. '_power_type', function(powerType)
        local color = PowerBarColor[powerType or 'MANA']
        f:SetStatusBarColor(color.r, color.g, color.b)
      end)
      local fs = f:CreateFontString(nil, 'ARTWORK', 'GameNormalNumberFont')
      fs:SetAllPoints()
      fs:SetJustifyH('CENTER')
      G.DataWatch(v.unit .. '_power', v.unit .. '_max_power', function(power, powerMax)
        f:SetMinMaxValues(0, powerMax)
        f:SetValue(power)
        fs:SetText(power .. ' / ' .. powerMax)
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

G.Eventer({
  PLAYER_ENTERING_WORLD = function()
    local Quartz3CastBarPlayer = _G.Quartz3CastBarPlayer
    if Quartz3CastBarPlayer then
      Quartz3CastBarPlayer:ClearAllPoints()
      Quartz3CastBarPlayer:SetPoint('BOTTOM', Minimap, 'TOP')
    else
      local CastingBarFrame = _G.CastingBarFrame
      CastingBarFrame.ignoreFramePositionManager = true
      CastingBarFrame:ClearAllPoints()
      CastingBarFrame:SetPoint('BOTTOM', 0, 275)
    end
  end,
})

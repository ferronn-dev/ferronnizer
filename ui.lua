local _, G = ...

-- TODO remove this addonmaker workaround
if not _G.GetXPExhaustion then
  return
end

local root = CreateFrame('Frame', 'FerronnizerRoot', UIParent)
root:SetAllPoints()
root:SetAlpha(0.75)

local unitFrames = {
  {
    anchor = function()
      return { 'CENTER', -200, -140 }
    end,
    parentKey = 'Player',
    unit = 'player',
  },
  {
    anchor = function()
      return { 'TOPRIGHT', root.Player, 'TOPLEFT', -20, 0 }
    end,
    parentKey = 'Pet',
    scale = 0.5,
    unit = 'pet',
  },
  {
    anchor = function()
      return { 'BOTTOMLEFT', root.Player, 'TOPLEFT', 0, 20 }
    end,
    event = 'GROUP_ROSTER_UPDATE',
    parentKey = 'Party1',
    scale = 0.5,
    unit = 'party1',
  },
  {
    anchor = function()
      return { 'BOTTOMLEFT', root.Party1, 'TOPLEFT', 0, 20 }
    end,
    event = 'GROUP_ROSTER_UPDATE',
    parentKey = 'Party2',
    scale = 0.5,
    unit = 'party2',
  },
  {
    anchor = function()
      return { 'BOTTOMLEFT', root.Party2, 'TOPLEFT', 0, 20 }
    end,
    event = 'GROUP_ROSTER_UPDATE',
    parentKey = 'Party3',
    scale = 0.5,
    unit = 'party3',
  },
  {
    anchor = function()
      return { 'BOTTOMLEFT', root.Party3, 'TOPLEFT', 0, 20 }
    end,
    event = 'GROUP_ROSTER_UPDATE',
    parentKey = 'Party4',
    scale = 0.5,
    unit = 'party4',
  },
  {
    anchor = function()
      return { 'CENTER', 200, -140 }
    end,
    event = 'PLAYER_TARGET_CHANGED',
    parentKey = 'Target',
    unit = 'target',
  },
  {
    anchor = function()
      return { 'CENTER', 0, -160 }
    end,
    event = 'PLAYER_FOCUS_CHANGED',
    parentKey = 'Focus',
    unit = 'focus',
  },
}

for _, uf in ipairs(unitFrames) do
  local v = CreateFrame('Button', nil, root, 'SecureUnitButtonTemplate')
  root[uf.parentKey] = v
  v.unit = uf.unit
  v:SetPoint(unpack(uf.anchor()))
  v:SetSize(160, 60)
  v:SetScale(uf.scale or 1)
  v:SetAttribute('unit', uf.unit)
  v:SetAttribute('*type1', 'target')
  v:SetAttribute('*type2', 'togglemenu')
  RegisterUnitWatch(v)
  v:RegisterForClicks('LeftButtonUp', 'RightButtonUp')

  v:SetScript('OnEnter', function()
    local unit = uf.unit
    GameTooltip:SetOwner(v, 'ANCHOR_TOP')
    GameTooltip:SetUnit(unit)
    if UnitIsUnit(unit, 'player') then
      GameTooltip:AddLine(('XP: %d/%d'):format(UnitXP(unit), UnitXPMax(unit)))
      GameTooltip:AddLine(('Rest: %s'):format(tostring(_G.GetXPExhaustion() or 'none')))
    end
    GameTooltip:Show()
  end)
  v:SetScript('OnLeave', function()
    GameTooltip:Hide()
  end)

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

  v.Auras = (function()
    local f = CreateFrame('Frame', nil, v, 'FerronnizerTemplateAuras')
    f:RegisterEvent('PLAYER_LOGIN')
    if uf.event then
      f:RegisterEvent(uf.event)
    end
    return f
  end)()
end

root.Pet.Happiness = (function()
  -- Adapted from PetFrame.lua
  local f = CreateFrame('Frame', nil, root.Pet)
  f:SetPoint('TOPRIGHT', root.Pet, 'TOPLEFT', -10, 0)
  f:SetSize(24, 23)
  local t = f:CreateTexture()
  t:SetAllPoints()
  t:SetTexture('Interface\\PetPaperDollFrame\\UI-PetHappiness')
  G.DataWatch('pet_happiness', function(happiness)
    t:SetTexCoord((function()
      if happiness == 1 then
        return 0.375, 0.5625, 0, 0.359375
      elseif happiness == 2 then
        return 0.1875, 0.375, 0, 0.359375
      else
        return 0, 0.1875, 0, 0.359375
      end
    end)())
  end)
  f.Texture = t
  return f
end)()

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

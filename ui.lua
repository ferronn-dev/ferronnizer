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
  local unit = uf.unit
  local v = CreateFrame('Button', nil, root, 'SecureUnitButtonTemplate')
  root[uf.parentKey] = v
  v:SetPoint(unpack(uf.anchor()))
  v:SetSize(160, 60)
  v:SetScale(uf.scale or 1)
  v:SetAttribute('unit', unit)
  v:SetAttribute('*type1', 'target')
  v:SetAttribute('*type2', 'togglemenu')
  RegisterUnitWatch(v)
  v:RegisterForClicks('LeftButtonUp', 'RightButtonUp')

  v:SetScript('OnEnter', function()
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
    G.DataWatch(unit .. '_level', unit .. '_name', function(level, name)
      fs:SetText(level .. ' - ' .. (name or ''))
    end)
    f.Text = fs
    local t = f:CreateTexture()
    t:SetAllPoints()
    G.DataWatch(unit .. '_class', function(class)
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
    G.DataWatch(unit .. '_class', function(class)
      f:SetStatusBarColor(GetClassColor(class))
    end)
    local fs = f:CreateFontString(nil, 'ARTWORK', 'GameNormalNumberFont')
    fs:SetAllPoints()
    fs:SetJustifyH('CENTER')
    G.DataWatch(unit .. '_health', unit .. '_max_health', function(health, healthMax)
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
    G.DataWatch(unit .. '_power_type', function(powerType)
      local color = PowerBarColor[powerType or 'MANA']
      f:SetStatusBarColor(color.r, color.g, color.b)
    end)
    local fs = f:CreateFontString(nil, 'ARTWORK', 'GameNormalNumberFont')
    fs:SetAllPoints()
    fs:SetJustifyH('CENTER')
    G.DataWatch(unit .. '_power', unit .. '_max_power', function(power, powerMax)
      f:SetMinMaxValues(0, powerMax)
      f:SetValue(power)
      fs:SetText(power .. ' / ' .. powerMax)
    end)
    f.Text = fs
    return f
  end)()

  v.Auras = (function()
    local f = CreateFrame('Frame', nil, v)
    f:SetPoint('TOPLEFT', 0, -60)
    f:SetSize(160, 100)
    f:RegisterUnitEvent('UNIT_AURA', unit)
    f:RegisterEvent('PLAYER_LOGIN')
    if uf.event then
      f:RegisterEvent(uf.event)
    end
    f.Kids = {}
    for row = 0, 4 do
      for col = 0, 7 do
        local frame = CreateFrame('Frame', nil, f, nil, row * 8 + col + 1)
        frame:SetPoint('TOPLEFT', col * 20, row * -20)
        frame:SetSize(20, 20)
        frame.Cooldown = CreateFrame('Cooldown', nil, frame, 'CooldownFrameTemplate')
        frame.Cooldown:SetReverse(true)
        frame.Icon = frame:CreateTexture(nil, 'ARTWORK')
        frame.Icon:SetAllPoints()
        frame.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        frame.Count = frame:CreateFontString(nil, 'ARTWORK', 'NumberFontNormalSmall')
        frame.Count:SetPoint('BOTTOMRIGHT')
        frame.Border = frame:CreateTexture(nil, 'OVERLAY')
        frame.Border:SetAllPoints()
        frame.Border:SetTexture('Interface\\Buttons\\UI-Debuff-Overlays')
        frame.Border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
        frame:SetScript('OnEnter', function(self)
          GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
          GameTooltip:SetUnitAura(unit, self.Index, self.Filter)
          GameTooltip:Show()
        end)
        frame:SetScript('OnLeave', function()
          GameTooltip:Hide()
        end)
        table.insert(f.Kids, frame)
      end
    end
    f:SetScript('OnEvent', function(self)
      local index, filter = 1, 'HELPFUL'
      for _, frame in ipairs(self.Kids) do
        local _, icon, count, dispelType, duration, expiration = UnitAura(unit, index, filter)
        if not icon and filter == 'HELPFUL' then
          index, filter = 1, 'HARMFUL'
          _, icon, count, dispelType, duration, expiration = UnitAura(unit, index, filter)
        end
        if not icon then
          frame.Index, frame.Filter = nil, nil
          frame:Hide()
        else
          frame.Index, frame.Filter = index, filter
          frame:Show()
          frame.Icon:SetTexture(icon)
          frame.Count:SetText(count and count > 0 and count or '')
          if dispelType then
            local color = DebuffTypeColor[dispelType]
            frame.Border:SetVertexColor(color.r, color.g, color.b)
            frame.Border:Show()
          else
            frame.Border:Hide()
          end
          frame.Cooldown:SetCooldown(expiration - duration, duration)
        end
        index = index + 1
      end
    end)
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

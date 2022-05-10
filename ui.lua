local _, G = ...

local root = CreateFrame('Frame', 'FerronnizerRoot', UIParent)
root:SetAllPoints()
root:SetAlpha(0.75)

local unitFrames = {
  {
    anchor = function()
      return 'CENTER', -200, -140
    end,
    parentKey = 'Player',
    unit = 'player',
  },
  {
    anchor = function()
      return 'TOPRIGHT', root.Player, 'TOPLEFT', -20, 0
    end,
    parentKey = 'Pet',
    scale = 0.5,
    unit = 'pet',
  },
  {
    anchor = function()
      return 'BOTTOMLEFT', root.Player, 'TOPLEFT', 0, 20
    end,
    parentKey = 'Party1',
    scale = 0.5,
    unit = 'party1',
  },
  {
    anchor = function()
      return 'BOTTOMLEFT', root.Party1, 'TOPLEFT', 0, 20
    end,
    parentKey = 'Party2',
    scale = 0.5,
    unit = 'party2',
  },
  {
    anchor = function()
      return 'BOTTOMLEFT', root.Party2, 'TOPLEFT', 0, 20
    end,
    parentKey = 'Party3',
    scale = 0.5,
    unit = 'party3',
  },
  {
    anchor = function()
      return 'BOTTOMLEFT', root.Party3, 'TOPLEFT', 0, 20
    end,
    parentKey = 'Party4',
    scale = 0.5,
    unit = 'party4',
  },
  {
    anchor = function()
      return 'CENTER', 200, -140
    end,
    parentKey = 'Target',
    unit = 'target',
  },
  {
    anchor = function()
      return 'CENTER', 0, -160
    end,
    parentKey = 'Focus',
    unit = 'focus',
  },
}

for _, uf in ipairs(unitFrames) do
  local unit = uf.unit
  local v = CreateFrame('Button', nil, root, 'SecureUnitButtonTemplate')
  root[uf.parentKey] = v
  v:SetPoint(uf.anchor())
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
    if UnitIsUnit(unit, 'player') and UnitLevel('player') < _G.GetMaxPlayerLevel() then
      GameTooltip:AddLine(('XP: %d/%d'):format(UnitXP(unit), UnitXPMax(unit)))
      GameTooltip:AddLine(('Rest: %s'):format(tostring(_G.GetXPExhaustion() or 'none')))
    end
    GameTooltip:Show()
  end)
  v:SetScript('OnLeave', function()
    GameTooltip:Hide()
  end)

  v.Health = (function()
    local f = CreateFrame('StatusBar', nil, v)
    f:SetPoint('TOPLEFT')
    f:SetSize(160, 40)
    f:SetStatusBarTexture('Interface\\Buttons\\WHITE8x8')
    G.DataWatch(unit .. '_class', function(class)
      f:SetStatusBarColor(GetClassColor(class))
    end)
    G.DataWatch(unit .. '_health', unit .. '_max_health', function(health, healthMax)
      f:SetMinMaxValues(0, healthMax)
      f:SetValue(health)
    end)
    return f
  end)()

  v.Health.Name = (function()
    local fs = v.Health:CreateFontString()
    fs:SetFontObject('GameFontDisable')
    fs:SetPoint('TOPLEFT', v.Health)
    fs:SetPoint('BOTTOMRIGHT', v.Health, 'RIGHT')
    fs:SetJustifyH('CENTER')
    G.DataWatch(unit .. '_level', unit .. '_name', function(level, name)
      fs:SetText(level .. ' - ' .. (name or ''))
    end)
    return fs
  end)()

  v.Health.Text = (function()
    local fs = v.Health:CreateFontString()
    fs:SetFontObject('GameFontDisable')
    fs:SetPoint('TOPLEFT', v.Health, 'LEFT')
    fs:SetPoint('BOTTOMRIGHT', v.Health)
    fs:SetJustifyH('CENTER')
    G.DataWatch(unit .. '_health', unit .. '_max_health', function(health, healthMax)
      fs:SetText(health .. ' / ' .. healthMax)
    end)
    return fs
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
    local fs = f:CreateFontString()
    fs:SetFontObject('GameFontDisable')
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
        frame.Count = frame:CreateFontString()
        frame.Count:SetFontObject('NumberFontNormalSmall')
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
    G.DataWatch(unit .. '_buffs', unit .. '_debuffs', function(buffs, debuffs)
      local index, auras = 1, buffs
      for _, frame in ipairs(f.Kids) do
        local aura = auras[index]
        if not aura and auras == buffs then
          index, auras = 1, debuffs
          aura = auras[index]
        end
        if not aura then
          frame.Index, frame.Filter = nil, nil
          frame:Hide()
        else
          frame.Index, frame.Filter = index, auras == buffs and 'HELPFUL' or 'HARMFUL'
          frame:Show()
          frame.Icon:SetTexture(aura.icon)
          frame.Count:SetText(aura.count and aura.count > 0 and aura.count or '')
          if aura.dispelType then
            local color = DebuffTypeColor[aura.dispelType]
            frame.Border:SetVertexColor(color.r, color.g, color.b)
            frame.Border:Show()
          else
            frame.Border:Hide()
          end
          frame.Cooldown:SetCooldown(aura.expiration - aura.duration, aura.duration)
        end
        index = index + 1
      end
    end)
    return f
  end)()
end

root.Player.Health.OnHateList = (function()
  local t = root.Player.Health:CreateTexture(nil, 'OVERLAY')
  t:SetTexture('Interface\\CharacterFrame\\UI-StateIcon')
  t:SetTexCoord(0.5, 1.0, 0, 0.484375)
  t:SetPoint('TOPRIGHT')
  t:SetSize(32, 32)
  G.DataWatch('player_on_hate_list', function(onHateList)
    t:SetShown(onHateList)
  end)
  return t
end)()

root.Player.Health.Resting = (function()
  local t = root.Player.Health:CreateTexture(nil, 'OVERLAY')
  t:SetTexture('Interface\\CharacterFrame\\UI-StateIcon')
  t:SetTexCoord(0, 0.5, 0, 0.421875)
  t:SetPoint('TOPLEFT')
  t:SetSize(31, 33)
  G.DataWatch('player_resting', function(resting)
    t:SetShown(resting)
  end)
  return t
end)()

root.Pet.Happiness = (function()
  -- Adapted from PetFrame.lua
  local t = root.Pet:CreateTexture()
  t:SetPoint('TOPRIGHT', root.Pet, 'TOPLEFT', -10, 0)
  t:SetSize(24, 23)
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
  return t
end)()

root.Clock = (function()
  local fs = root:CreateFontString()
  fs:SetFontObject('GameFontNormalSmall')
  fs:SetPoint('TOPRIGHT')
  fs:SetJustifyH('RIGHT')
  fs:SetJustifyV('TOP')
  G.DataWatch('game_time', function(s)
    fs:SetText(s)
  end)
  return fs
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

local _, G = ...

local function ifClassic(x)
  return WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and x or nil
end

G.Eventer({
  PLAYER_LOGIN = function()
    G.ReparentFrame(MinimapBackdrop)
    G.ReparentFrame(MinimapCluster)
    G.ReparentFrame(TimeManagerClockButton)
    Minimap:SetParent(UIParent)
    Minimap:SetMaskTexture('Interface\\Buttons\\WHITE8X8')
    Minimap:SetScale(0.75)
    Minimap:SetZoom(0)
    Minimap:SetPoint('TOP', UIParent, 'CENTER', 0, -200)
    if MiniMapTracking then
      MiniMapTracking:SetParent(Minimap)
      MiniMapTracking:ClearAllPoints()
      MiniMapTracking:SetPoint('TOPLEFT', Minimap, 'TOPLEFT')
    end
  end,
  PLAYER_ENTERING_WORLD = ifClassic(function()
    local t = GetTrackingTexture()
    if t then
      MiniMapTrackingIcon:SetTexture(t)
      MiniMapTrackingFrame:Show()
    end
  end),
})

do
  local targetHandler = CreateFrame('Frame')
  targetHandler:RegisterEvent('PLAYER_TARGET_CHANGED')
  targetHandler:RegisterUnitEvent('UNIT_HEALTH', 'target')
  targetHandler:RegisterUnitEvent('UNIT_MAXHEALTH', 'target')
  targetHandler:RegisterUnitEvent('UNIT_POWER_UPDATE', 'target')
  local sib = _G.TargetFrameTextureFrameName
  if sib then
    local hbt = sib:GetParent():CreateFontString('TargetFrameHealthBarText', sib:GetDrawLayer(), 'TextStatusBarText')
    hbt:SetPoint('CENTER', -50, 3)
    local mbt = sib:GetParent():CreateFontString('TargetFrameManaBarText', sib:GetDrawLayer(), 'TextStatusBarText')
    mbt:SetPoint('CENTER', -50, -8)
    targetHandler:SetScript('OnEvent', function()
      hbt:SetText(UnitHealth('target') .. ' / ' .. UnitHealthMax('target'))
      local pm = UnitPowerMax('target')
      mbt:SetText(pm == 0 and '' or (UnitPower('target') .. ' / ' .. pm))
    end)
  end
end

-- TODO put this somewhere more appropriate
G.Eventer({
  PLAYER_ENTERING_WORLD = function()
    PlayerFrame:Hide()
    TargetFrame:SetUserPlaced(true)
    TargetFrame:ClearAllPoints()
    TargetFrame:SetPoint('CENTER', 200, -100)
    _G.CastingBarFrame.ignoreFramePositionManager = true
    CastingBarFrame:ClearAllPoints()
    CastingBarFrame:SetPoint('BOTTOM', 0, 275)
  end,
})

local function createHealthFrame(np)
  local ht
  return {'UNIT_HEALTH', 'UNIT_MAXHEALTH'}, function(unit)
    if not ht then
      ht = np.UnitFrame.healthBar:CreateFontString()
      ht:SetFontObject(NumberFont_Small)
      ht:SetPoint('CENTER')
    end
    local hp, hpm = UnitHealth(unit), UnitHealthMax(unit)
    ht:SetText(hp..' / '..hpm)
  end
end

local constructors = {createHealthFrame}

local nameplateData = {}

local function onCreate(np)
  local datas = {}
  for _, constructor in ipairs(constructors) do
    local events, func = constructor(np)
    local frame = CreateFrame('Frame')
    frame:SetScript('OnEvent', function(_, _, unit)
      func(unit)
    end)
    table.insert(datas, { frame = frame, events = events, func = func })
  end
  nameplateData[np] = datas
end

local function onAdd(unitToken)
  local np = C_NamePlate.GetNamePlateForUnit(unitToken)
  for _, data in ipairs(nameplateData[np]) do
    data.func(unitToken)
    for _, ev in ipairs(data.events) do
      data.frame:RegisterUnitEvent(ev, unitToken)
    end
  end
end

local function onRemove(unitToken)
  local np = C_NamePlate.GetNamePlateForUnit(unitToken)
  for _, data in ipairs(nameplateData[np]) do
    data.frame:UnregisterAllEvents()
  end
end

G.Eventer({
  NAME_PLATE_CREATED = onCreate,
  NAME_PLATE_UNIT_ADDED = onAdd,
  NAME_PLATE_UNIT_REMOVED = onRemove,
})

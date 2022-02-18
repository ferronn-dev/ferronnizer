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

local targetHandler = CreateFrame('Frame')
targetHandler:RegisterEvent('PLAYER_TARGET_CHANGED')
targetHandler:RegisterUnitEvent('UNIT_HEALTH', 'target')
targetHandler:RegisterUnitEvent('UNIT_MAXHEALTH', 'target')
targetHandler:RegisterUnitEvent('UNIT_POWER_UPDATE', 'target')

-- TODO put this somewhere more appropriate
G.Eventer({
  PLAYER_ENTERING_WORLD = function()
    PlayerFrame:SetUserPlaced(true)
    PlayerFrame:ClearAllPoints()
    PlayerFrame:SetPoint('CENTER', -200, -100)
    TargetFrame:SetUserPlaced(true)
    TargetFrame:ClearAllPoints()
    TargetFrame:SetPoint('CENTER', 200, -100)
    local sib = TargetFrameTextureFrameName
    local hbt = sib:GetParent():CreateFontString('TargetFrameHealthBarText', sib:GetDrawLayer(), 'TextStatusBarText')
    hbt:SetPoint('CENTER', -50, 3)
    local mbt = sib:GetParent():CreateFontString('TargetFrameManaBarText', sib:GetDrawLayer(), 'TextStatusBarText')
    mbt:SetPoint('CENTER', -50, -8)
    targetHandler:SetScript('OnEvent', function(_, ev)
      hbt:SetText(UnitHealth('target') .. ' / ' .. UnitHealthMax('target'))
      local pm = UnitPowerMax('target')
      mbt:SetText(pm == 0 and '' or (UnitPower('target') .. ' / ' .. pm))
    end)
    _G.CastingBarFrame.ignoreFramePositionManager = true
    CastingBarFrame:ClearAllPoints()
    CastingBarFrame:SetPoint('BOTTOM', 0, 275)
  end,
})

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

-- TODO put this somewhere more appropriate
G.Eventer({
  PLAYER_ENTERING_WORLD = function()
    _G.CastingBarFrame.ignoreFramePositionManager = true
    CastingBarFrame:ClearAllPoints()
    CastingBarFrame:SetPoint('BOTTOM', 0, 275)
  end,
})

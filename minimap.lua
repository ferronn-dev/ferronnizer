local _, G = ...

G.Eventer({
  PLAYER_LOGIN = function()
    G.ReparentFrame(MinimapBackdrop)
    G.ReparentFrame(MinimapCluster)
    G.ReparentFrame(TimeManagerClockButton)
    Minimap:SetParent(UIParent)
    Minimap:SetMaskTexture('Interface\\Buttons\\WHITE8X8')
    Minimap:SetScale(0.75)
    Minimap:SetZoom(0)
    Minimap:ClearAllPoints()
    Minimap:SetPoint('BOTTOM', UIParent, 'BOTTOM', 0, 220)
    MiniMapTracking:SetParent(Minimap)
    MiniMapTracking:ClearAllPoints()
    MiniMapTracking:SetPoint('TOPLEFT', Minimap, 'TOPLEFT')
  end,
  PLAYER_ENTERING_WORLD = function()
    local t = GetTrackingTexture()
    if t then
      MiniMapTrackingIcon:SetTexture(t)
      MiniMapTracking:Show()
    end
  end,
})

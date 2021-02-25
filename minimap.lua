local _, G = ...

G.Eventer({
  PLAYER_LOGIN = function()
    local toReparent = {
      MainMenuBar,
      MinimapBackdrop,
      MinimapCluster,
      TimeManagerClockButton,
    }
    for _, f in ipairs(toReparent) do
      G.ReparentFrame(f)
    end
    Minimap:SetParent(UIParent)
    Minimap:SetMaskTexture('Interface\\Buttons\\WHITE8X8')
    Minimap:SetScale(0.75)
    Minimap:SetZoom(0)
    Minimap:SetPoint('TOP', UIParent, 'CENTER', 0, -200)
  end,
  PLAYER_ENTERING_WORLD = function()
    local t = GetTrackingTexture()
    if t then
      MiniMapTrackingIcon:SetTexture(t)
      MiniMapTrackingFrame:Show()
    end
  end,
})

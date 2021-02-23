local _, G = ...

G.Eventer({
  PLAYER_LOGIN = function()
    local toReparent = {
      MainMenuBar,
      MinimapBackdrop,
      MinimapCluster,
      TimeManagerClockButton,
      PlayerFrame,
      TargetFrame,
    }
    local frame = CreateFrame('Frame')
    frame:Hide()
    for _, f in ipairs(toReparent) do
      f:SetParent(frame)
    end
    ChatFrame1:ClearAllPoints()
    ChatFrame1:SetClampRectInsets(0, 0, 0, 0)
    ChatFrame1:SetPoint('BOTTOMLEFT', UIParent, 2, 30)
    ChatFrame1:SetHeight(180)
    ChatFrame1:SetWidth(400)
    ChatFrame1:SetUserPlaced(true)
    Minimap:SetParent(UIParent)
    Minimap:SetMaskTexture('Interface\\Buttons\\WHITE8X8')
    Minimap:SetScale(0.75)
    Minimap:SetZoom(0)
    Minimap:SetPoint('TOP', UIParent, 'CENTER', 0, -200)
  end,
})

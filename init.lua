local _, G = ...

G.Eventer({
  PLAYER_LOGIN = function()
    G.ReparentFrame(PlayerFrame)
    G.ReparentFrame(TargetFrame)
    ChatFrame1:ClearAllPoints()
    ChatFrame1:SetClampRectInsets(0, 0, 0, 0)
    ChatFrame1:SetPoint('BOTTOMLEFT', UIParent, 2, 30)
    ChatFrame1:SetHeight(180)
    ChatFrame1:SetWidth(400)
    ChatFrame1:SetUserPlaced(true)
  end,
})

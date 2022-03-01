local addonName, G = ...

G.Eventer({
  ADDON_ACTION_BLOCKED = function(addon, msg)
    if addon == addonName then
      print('Action blocked: ' .. msg)
    end
  end,
  PLAYER_LOGIN = function()
    ChatFrame1:ClearAllPoints()
    ChatFrame1:SetClampRectInsets(0, 0, 0, 0)
    ChatFrame1:SetPoint('BOTTOMLEFT', UIParent, 2, 30)
    ChatFrame1:SetHeight(180)
    ChatFrame1:SetWidth(400)
    ChatFrame1:SetUserPlaced(true)
  end,
})

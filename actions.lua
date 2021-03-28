local addonName, G = ...
local LAB10 = LibStub('LibActionButton-1.0')
local header = CreateFrame('Frame', nil, UIParent, 'SecureHandlerStateTemplate')
header:SetAllPoints()
local button = LAB10:CreateButton(1, addonName .. 'ActionButton1', header)
button:SetPoint('BOTTOMRIGHT')
button:DisableDragNDrop(true)

G.Eventer({
  PLAYER_LOGIN = function()
    button:SetState(0, 'spell', 9472)
  end,
})

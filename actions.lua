local addonName = ...
local LAB10 = LibStub('LibActionButton-1.0')
local header = CreateFrame('Frame', nil, nil, 'SecureHandlerStateTemplate')
LAB10:CreateButton(1, addonName .. 'ActionButton1', header)

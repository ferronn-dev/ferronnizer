local addonName, G = ...

--[[
local characters = {
  ['Shydove-Westfall'] = {
    [1] = {
      actionText = 'GH4',
      mouseover = true,
      spell = 'Greater Heal(Rank 4)',
    },
    [2] = {
      actionText = 'GH2',
      mouseover = true,
      spell = 'Greater Heal(Rank 2)',
    },
    [3] = {
      actionText = 'H4',
      mouseover = true,
      spell = 'Heal(Rank 4)',
    },
    [4] = {
      actionText = 'Stop',
      macro = '/stopcasting',
      tooltip = 'Stop Casting',
    },
    [13] = {
      actionText = 'FH7',
      mouseover = true,
      spell = 'Flash Heal(Rank 7)',
    },
    [14] = {
      actionText = 'FH3',
      mouseover = true,
      spell = 'Flash Heal(Rank 3)',
    },
    [15] = {
      actionText = 'FH2',
      mouseover = true,
      spell = 'Flash Heal(Rank 2)',
    },
    [16] = {
      actionText = 'Stop',
      macro = '/stopcasting',
      tooltip = 'Stop Casting',
    },
  },
}
]]--

local buttonMixin = {
  GetActionText = nil,
  GetCharges = nil,
  GetCooldown = nil,
  GetCount = nil,
  GetLossOfControlCooldown = nil,
  GetSpellId = nil,
  GetTexture = nil,
  HasAction = nil,
  IsAttack = nil,
  IsAutoRepeat = nil,
  IsConsumableOrStackable = nil,
  IsCurrentlyActive = nil,
  IsEquipped = nil,
  IsUnitInRange = nil,
  IsUsable = nil,
  SetTooltip = nil,
}

local buttons = (function()
  local LAB10 = LibStub('LibActionButton-1.0')
  local prefix = addonName .. 'ActionButton'
  local header = CreateFrame('Frame', prefix .. 'Header', UIParent, 'SecureHandlerStateTemplate')
  local buttons = {}
  for i = 1, 49 do
    local button = LAB10:CreateButton(i, prefix .. i, header)
    button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    button:DisableDragNDrop(true)
    Mixin(button, buttonMixin)
    table.insert(buttons, button)
  end
  for i, button in ipairs(buttons) do
    if i <= 36 then
      button:SetPoint('BOTTOM', buttons[i + 12], 'TOP')
    end
    if (i - 1) % 12 < 5 then
      button:SetPoint('RIGHT', buttons[i + 1], 'LEFT')
    elseif (i - 1) % 12 > 6 then
      button:SetPoint('LEFT', buttons[i - 1], 'RIGHT')
    end
  end
  buttons[42]:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOM')
  buttons[43]:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOM')
  return buttons
end)()

do
  local dragNDropToggle = true
  G.PreClickButton('ToggleActionDragButton', nil, function()
    dragNDropToggle = not dragNDropToggle
    for _, button in ipairs(buttons) do
      button:DisableDragNDrop(dragNDropToggle)
    end
  end)
end

G.Eventer({
  PLAYER_LOGIN = function()
    G.ReparentFrame(MainMenuBar)
    for i, button in ipairs(buttons) do
      button:SetState(0, 'action', i)
    end
  end,
})

local addonName, G = ...

local libCount = LibStub('LibClassicSpellActionCount-1.0')

local types = {
  default = {
    GetActionText = function(action)
      return action.actionText or ""
    end,
    GetCooldown = function()
      return 0, 0, 0
    end,
    GetCount = function()
      return 0
    end,
    GetTexture = function(action)
      return action.texture
    end,
    HasAction = function()
      return true
    end,
    IsConsumableOrStackable = function()
      return false
    end,
    IsCurrentlyActive = function()
      return false
    end,
    IsUnitInRange = function()
      return nil
    end,
    IsUsable = function()
      return false
    end,
    SetTooltip = function(action)
      if action.tooltip then
        return GameTooltip:SetText(action.tooltip)
      end
    end,
  },
  item = {
    GetCooldown = function(item)
      return GetItemCooldown(item)
    end,
    GetCount = function(item)
      return GetItemCount(item)
    end,
    GetTexture = function(item)
      return GetItemIcon(item)
    end,
    IsConsumableOrStackable = function(item)
      -- LAB bug
      local stack = select(8, GetItemInfo(item))
      return IsConsumableItem(item) or (stack and stack > 1)
    end,
    IsCurrentlyActive = function(item)
      return IsCurrentItem(item)
    end,
    IsUnitInRange = function(item, unit)
      return IsItemInRange(item, unit)
    end,
    IsUsable = function(item)
      return IsUsableItem(item)
    end,
    SetTooltip = function(item)
      return GameTooltip:SetHyperlink('item:'..item)
    end,
  },
  macro = {
    IsUsable = function()
      return true
    end,
  },
  spell = {
    GetCooldown = function(spell)
      return GetSpellCooldown(spell)
    end,
    GetCount = function(spell)
      -- LAB bug
      return libCount:GetSpellReagentCount(spell)
    end,
    GetTexture = function(spell)
      return GetSpellTexture(spell)
    end,
    IsConsumableOrStackable = function(spell)
      return IsConsumableSpell(spell)
    end,
    IsCurrentlyActive = function(spell)
      return IsCurrentSpell(spell)
    end,
    IsUnitInRange = function(spell, unit)
      local id = select(7, GetSpellInfo(spell))
      local slot = FindSpellBookSlotBySpellID(id)
      return IsSpellInRange(slot, 'spell', unit)
    end,
    IsUsable = function(spell)
      return IsUsableSpell(spell)
    end,
    SetTooltip = function(spell)
      local id = select(7, GetSpellInfo(spell))
      GameTooltip:SetSpellByID(id)
      local subtext = GetSpellSubtext(id)
      if subtext then
        GameTooltipTextRight1:SetText(subtext)
        GameTooltipTextRight1:Show()
        GameTooltip:Show()
      end
    end,
  },
}

local buttons = (function()
  local LAB10 = LibStub('LibActionButton-1.0')
  -- LAB bug
  G.Eventer({
    BAG_UPDATE_DELAYED = function()
      LAB10.eventFrame:GetScript('OnEvent')(LAB10.eventFrame, 'SPELL_UPDATE_CHARGES')
    end,
  })
  local prefix = addonName .. 'ActionButton'
  local header = CreateFrame('Frame', prefix .. 'Header', UIParent, 'SecureHandlerStateTemplate')
  local buttons = {}
  for i = 1, 49 do
    local button = LAB10:CreateButton(i, prefix .. i, header)
    button:SetAttribute('state', 1)
    button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    button:DisableDragNDrop(true)
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
    local charName = UnitName('player')..'-'..GetRealmName()
    local actions = G.Characters[charName] or {}
    local buttonMixin = {}
    for k, v in pairs(types.default) do
      buttonMixin[k] = function(self, ...)
        local action = actions[self._state_action] or {}
        if action.spell and types.spell[k] then
          return types.spell[k](action.spell, ...)
        elseif action.item and types.item[k] then
          return types.item[k](action.item, ...)
        elseif action.macro and types.macro[k] then
          return types.macro[k](action.macro, ...)
        else
          return v(action)
        end
      end
    end
    for i, button in ipairs(buttons) do
      local action = actions[i]
      if not action then
        button:SetState(1, 'action', i)
      else
        Mixin(button, buttonMixin)
        button:SetState(1, 'empty', i)
        button:SetAttribute('type', 'macro')
        button:SetAttribute('macrotext', (function()
          if action.item then
            return '/use item:'..action.item
          elseif action.spell then
            return (
               '/dismount\n/stand\n/cast'..
                (action.mouseover and ' [@mouseover,help,nodead][] ' or ' ')..
                action.spell)
          else
            return action.macro
          end
        end)())
      end
    end
  end,
})

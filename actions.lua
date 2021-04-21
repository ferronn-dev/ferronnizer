local addonName, G = ...

local libCount = LibStub('LibClassicSpellActionCount-1.0')

-- TODO eliminate overlap with drink.lua
local getDrinkItem, getEatItem = (function()
  local function getConsumableFn(db)
    local function getItem()
      for _, consumable in ipairs(db) do
        local item = unpack(consumable)
        if GetItemCount(item) > 0 then
          return item
        end
      end
      return db[#db][1]  -- give up and return the last thing
    end
    local lastItem, lastTime
    return function()
      local now = GetTime()
      if now ~= lastTime then
        lastTime = now
        lastItem = getItem()
      end
      return lastItem
    end
  end
  return getConsumableFn(G.DrinkDB), getConsumableFn(G.FoodDB)
end)()

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
    GetMacroText = function()
      return ''
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
  drink = {
    GetCooldown = function()
      return GetItemCooldown(getDrinkItem())
    end,
    GetCount = function()
      return GetItemCount(getDrinkItem())
    end,
    GetMacroText = function()
      return '/click DrinkButton'
    end,
    GetTexture = function()
      return GetItemIcon(getDrinkItem())
    end,
    IsConsumableOrStackable = function()
      return true
    end,
    IsUsable = function()
      return IsUsableItem(getDrinkItem())
    end,
    SetTooltip = function()
      return GameTooltip:SetHyperlink('item:'..getDrinkItem())
    end,
  },
  eat = {
    GetCooldown = function()
      return GetItemCooldown(getEatItem())
    end,
    GetCount = function()
      return GetItemCount(getEatItem())
    end,
    GetMacroText = function()
      return '/click EatButton'
    end,
    GetTexture = function()
      return GetItemIcon(getEatItem())
    end,
    IsConsumableOrStackable = function()
      return true
    end,
    IsUsable = function()
      return IsUsableItem(getEatItem())
    end,
    SetTooltip = function()
      return GameTooltip:SetHyperlink('item:'..getEatItem())
    end,
  },
  item = {
    GetCooldown = function(action)
      return GetItemCooldown(action.item)
    end,
    GetCount = function(action)
      return GetItemCount(action.item)
    end,
    GetMacroText = function(action)
      return '/use item:'..action.item
    end,
    GetTexture = function(action)
      return GetItemIcon(action.item)
    end,
    IsConsumableOrStackable = function(action)
      -- LAB bug
      local stack = select(8, GetItemInfo(action.item))
      return IsConsumableItem(action.item) or (stack and stack > 1)
    end,
    IsCurrentlyActive = function(action)
      return IsCurrentItem(action.item)
    end,
    IsUnitInRange = function(action, unit)
      return IsItemInRange(action.item, unit)
    end,
    IsUsable = function(action)
      return IsUsableItem(action.item)
    end,
    SetTooltip = function(action)
      return GameTooltip:SetHyperlink('item:'..action.item)
    end,
  },
  macro = {
    GetMacroText = function(action)
      return action.macro
    end,
    IsUsable = function()
      return true
    end,
  },
  spell = {
    GetCooldown = function(action)
      return GetSpellCooldown(action.spell)
    end,
    GetCount = function(action)
      -- LAB bug
      return libCount:GetSpellReagentCount(action.spell)
    end,
    GetMacroText = function(action)
      return (
         '/dismount\n/stand\n/cast'..
         (action.mouseover and ' [@mouseover,help,nodead][] ' or ' ')..
         action.spell)
    end,
    GetTexture = function(action)
      return GetSpellTexture(action.spell)
    end,
    IsConsumableOrStackable = function(action)
      return IsConsumableSpell(action.spell)
    end,
    IsCurrentlyActive = function(action)
      return IsCurrentSpell(action.spell)
    end,
    IsUnitInRange = function(action, unit)
      local id = select(7, GetSpellInfo(action.spell))
      local slot = FindSpellBookSlotBySpellID(id)
      return IsSpellInRange(slot, 'spell', unit)
    end,
    IsUsable = function(action)
      return IsUsableSpell(action.spell)
    end,
    SetTooltip = function(action)
      local id = select(7, GetSpellInfo(action.spell))
      GameTooltip:SetSpellByID(id)
      local subtext = GetSpellSubtext(id)
      if subtext then
        GameTooltipTextRight1:SetText(subtext)
        GameTooltipTextRight1:SetTextColor(0.5, 0.5, 0.5)
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
  for i = 1, 48 do
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
        for ty in pairs(types) do
          if action[ty] and types[ty][k] then
            return types[ty][k](action, ...)
          end
        end
        return v(action, ...)
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
        button:SetAttribute('macrotext', button:GetMacroText())
      end
    end
  end,
})

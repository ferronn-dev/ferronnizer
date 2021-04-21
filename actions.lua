local addonName, G = ...

local libCount = LibStub('LibClassicSpellActionCount-1.0')

-- TODO eliminate overlap with drink.lua
local function getConsumable(db)
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

local function makeButtons(actions)
  local LAB10 = LibStub('LibActionButton-1.0')
  -- LAB bug
  G.Eventer({
    BAG_UPDATE_DELAYED = function()
      LAB10.eventFrame:GetScript('OnEvent')(LAB10.eventFrame, 'SPELL_UPDATE_CHARGES')
    end,
  })
  local prefix = addonName .. 'ActionButton'
  local header = CreateFrame('Frame', prefix .. 'Header', UIParent, 'SecureHandlerStateTemplate')
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
  local buttons = {}
  for i = 1, 48 do
    local action = actions[i]
    local button = (function()
      if action and (action.drink or action.eat) then
        local button = CreateFrame(
            'CheckButton', prefix .. i, header, 'ActionButtonTemplate, SecureActionButtonTemplate')
        button.HotKey:SetFont(button.HotKey:GetFont(), 13, 'OUTLINE')
        button.HotKey:SetVertexColor(0.75, 0.75, 0.75)
        button.HotKey:SetPoint('TOPLEFT', button, 'TOPLEFT', -2, -4)
        button.Count:SetFont(button.Count:GetFont(), 16, 'OUTLINE')
        local db = action.drink and G.DrinkDB or G.FoodDB
        button:SetScript('OnEvent', function()
          local item = getConsumable(db)
          local count = GetItemCount(item)
          button.Count:SetText(count > 9999 and '*' or count)
          button.icon:SetTexture(GetItemIcon(item))
        end)
        button:RegisterEvent('BAG_UPDATE_DELAYED')
        button:SetAttribute('type', 'macro')
        button:SetAttribute('macrotext', '/click ' .. (action.drink and 'Drink' or 'Eat') .. 'Button')
        return button
      else
        local button = LAB10:CreateButton(i, prefix .. i, header)
        button:SetAttribute('state', 1)
        button:DisableDragNDrop(true)
        if not action then
          button:SetState(1, 'action', i)
        else
          Mixin(button, buttonMixin)
          button:SetState(1, 'empty', i)
          button:SetAttribute('type', 'macro')
          button:SetAttribute('macrotext', button:GetMacroText())
        end
        return button
      end
    end)()
    button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
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
end

G.Eventer({
  PLAYER_LOGIN = function()
    G.ReparentFrame(MainMenuBar)
    local charName = UnitName('player')..'-'..GetRealmName()
    local actions = G.Characters[charName] or {}
    local buttons = makeButtons(actions)
    do
      local dragNDropToggle = true
      G.PreClickButton('ToggleActionDragButton', nil, function()
        dragNDropToggle = not dragNDropToggle
        for _, button in ipairs(buttons) do
          if button:GetAttribute('labtype-1') == 'action' then
            button:DisableDragNDrop(dragNDropToggle)
          end
        end
      end)
    end
  end,
})

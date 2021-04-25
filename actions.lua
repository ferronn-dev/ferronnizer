local addonName, G = ...

local LAB10 = LibStub('LibActionButton-1.0')
local keyBound = LibStub('LibKeyBound-1.0')
local libCount = LibStub('LibClassicSpellActionCount-1.0')

-- LAB bug
G.Eventer({
  BAG_UPDATE_DELAYED = function()
    LAB10.eventFrame:GetScript('OnEvent')(LAB10.eventFrame, 'SPELL_UPDATE_CHARGES')
  end,
})

local prefix = addonName .. 'ActionButton'
local header = CreateFrame('Frame', prefix .. 'Header', UIParent, 'SecureHandlerStateTemplate')

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

local function makeCustomActionButton(i, action)
  local button = CreateFrame(
      'CheckButton', prefix .. i, header, 'ActionButtonTemplate, SecureActionButtonTemplate')
  button.HotKey:SetFont(button.HotKey:GetFont(), 13, 'OUTLINE')
  button.HotKey:SetVertexColor(0.75, 0.75, 0.75)
  button.HotKey:SetPoint('TOPLEFT', button, 'TOPLEFT', -2, -4)
  button.Count:SetFont(button.Count:GetFont(), 16, 'OUTLINE')
  button:SetNormalTexture('Interface\\Buttons\\UI-Quickslot2')
  button.NormalTexture:SetTexCoord(0, 0, 0, 0)
  if action.actionText then
    button.Name:SetText(action.actionText)
  end
  if action.texture then
    button.icon:SetTexture(action.texture)
  elseif action.buff then
    button.icon:SetTexture(135938)
  end
  local currentItem, updateItem = (function()
    local db = action.drink and G.DrinkDB or action.eat and G.FoodDB
    if not db then
      return nil, nil
    end
    local function computeItem()
      for _, consumable in ipairs(db) do
        local item = unpack(consumable)
        if GetItemCount(item) > 0 then
          return item
        end
      end
      return db[#db][1]  -- give up and return the last thing
    end
    local item
    local function currentItem() return item end
    local function updateItem()
      item = computeItem()
      local count = GetItemCount(item)
      button.Count:SetText(count > 9999 and '*' or count)
      button.icon:SetTexture(GetItemIcon(item))
      button.icon:Show()
      button:SetAttribute('macrotext', '/use item:' .. item)
    end
    updateItem()
    return currentItem, updateItem
  end)()
  button:SetScript('OnEnter', function()
    GameTooltip:SetOwner(button, ANCHOR_NONE)
    if currentItem then
      GameTooltip:SetHyperlink('item:' .. currentItem())
    elseif action.tooltip then
      GameTooltip:SetText(action.tooltip)
    end
  end)
  button:SetScript('OnLeave', function()
    GameTooltip:Hide()
  end)
  button:SetScript('PostClick', function()
    button:SetChecked(false)
  end)
  local pending = false
  button:SetScript('OnEvent', (function()
    local handlers = {
      BAG_UPDATE_DELAYED = updateItem and function()
        if InCombatLockdown() then
          pending = true
        else
          updateItem()
        end
      end,
      PLAYER_REGEN_ENABLED = updateItem and function()
        if pending then
          pending = false
          updateItem()
        end
      end,
      UPDATE_BINDINGS = function()
        local key = _G.GetBindingKey('CLICK ' .. button:GetName() .. ':LeftButton')
        if key then
          button.HotKey:SetText(keyBound:ToShortKey(key))
          button.HotKey:Show()
        else
          button.HotKey:Hide()
        end
      end,
    }
    for ev in pairs(handlers) do
      button:RegisterEvent(ev)
    end
    return function(_, ev, ...)
      handlers[ev](...)
    end
  end)())
  button:SetAttribute('type', 'macro')
  if action.macro then
    button:SetAttribute('macrotext', action.macro)
  elseif action.buff then
    button:SetAttribute('macrotext', '/click ' .. addonName .. 'BuffButton')
  end
  return button
end

local function makeCustomLabButton(i, action)
  local button = LAB10:CreateButton(i, prefix .. i, header)
  button:SetAttribute('state', 1)
  button:DisableDragNDrop(true)
  Mixin(button, (function()
    local buttonMixin = {}
    for k, v in pairs(types.default) do
      local fn = (function()
        for ty in pairs(types) do
          if action[ty] and types[ty][k] then
            return types[ty][k]
          end
        end
        return v
      end)()
      buttonMixin[k] = function(_, ...)
        return fn(action, ...)
      end
    end
    return buttonMixin
  end)())
  button:SetState(1, 'empty', i)
  button:SetAttribute('type', 'macro')
  button:SetAttribute('macrotext', button:GetMacroText())
  return button
end

local function makeCustomActionButtons(actions)
  local buttons = {}
  for i = 1, 48 do
    local action = actions[i]
    local button = (function()
      if action and (action.drink or action.eat or action.macro or action.buff) then
        return makeCustomActionButton(i, action)
      elseif action then
        return makeCustomLabButton(i, action)
      else
        return CreateFrame('Button', prefix .. i, header, 'ActionButtonTemplate')
      end
    end)()
    table.insert(buttons, button)
  end
  return buttons
end

local function makeOnlyLabButtons()
  local buttons = {}
  for i = 1, 48 do
    local button = LAB10:CreateButton(i, prefix .. i, header)
    button:SetAttribute('state', 1)
    button:DisableDragNDrop(true)
    button:SetState(1, 'action', i)
    table.insert(buttons, button)
  end
  -- Only create toggle button when it's just LAB action buttons.
  local dragNDropToggle = true
  G.PreClickButton('ToggleActionDragButton', nil, function()
    dragNDropToggle = not dragNDropToggle
    for _, button in ipairs(buttons) do
      button:DisableDragNDrop(dragNDropToggle)
    end
  end)
  return buttons
end

local function makeButtons(actions)
  local buttons = actions and makeCustomActionButtons(actions) or makeOnlyLabButtons()
  for i, button in ipairs(buttons) do
    button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
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
end

G.Eventer({
  PLAYER_LOGIN = function()
    G.ReparentFrame(MainMenuBar)
    local charName = UnitName('player')..'-'..GetRealmName()
    local actions = G.Characters[charName]
    makeButtons(actions)
  end,
})

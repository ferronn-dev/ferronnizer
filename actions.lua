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

local labSpell = {
  GetActionText = function(action)
    return action.actionText or ""
  end,
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
  HasAction = function()
    return true
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
}

local function updateCooldown(button, cdfn)
  local start, duration, enable, modRate = cdfn()
  _G.CooldownFrame_Set(button.cooldown, start, duration, enable, false, modRate)
end

local function customTypes(button, action)
  local function updateCount(item)
    local count = GetItemCount(item)
    button.Count:SetText(count > 9999 and '*' or count)
  end
  local function consume(mealDB, potionDB)
    local function macroText(db)
      local s = ''
      for _, consumable in ipairs(db) do
        s = s .. '/use item:' .. consumable[1] .. '\n'
      end
      return s
    end
    local currentDB
    local function computeItem()
      for _, consumable in ipairs(currentDB) do
        local item = unpack(consumable)
        if GetItemCount(item) > 0 then
          return item
        end
      end
      return currentDB[#currentDB][1]  -- give up and return the last thing
    end
    local item
    local function getCooldown()
      return GetItemCooldown(item)
    end
    local function updateItem()
      item = computeItem()
      updateCount(item)
      updateCooldown(button, getCooldown)
      button.icon:SetTexture(GetItemIcon(item))
      button.icon:Show()
    end
    local function updateDB(db)
      currentDB = db
      button:SetAttribute('macrotext', macroText(db))
      updateItem()
    end
    return {
      getCooldown = getCooldown,
      handlers = {
        BAG_UPDATE_DELAYED = function()
          updateItem()
        end,
        PLAYER_REGEN_DISABLED = function()
          updateDB(potionDB)
        end,
        PLAYER_REGEN_ENABLED = function()
          updateDB(mealDB)
        end,
      },
      init = function()
        updateDB(mealDB)
      end,
      setTooltip = function()
        GameTooltip:SetHyperlink('item:' .. item)
      end,
    }
  end
  local function getGcdCooldown()
    return GetSpellCooldown(29515)
  end
  return {
    buff = {
      getCooldown = getGcdCooldown,
      handlers = {
        BAG_UPDATE_DELAYED = action.reagent and function()
          updateCount(action.reagent)
        end,
      },
      init = function()
        button.icon:SetTexture(135938)
        button:SetAttribute('macrotext', '/click ' .. addonName .. 'BuffButton')
      end,
      setTooltip = function()
        GameTooltip:SetText('Buff')
      end,
    },
    drink = consume(G.DrinkDB, G.ManaPotionDB),
    eat = consume(G.FoodDB, G.HealthPotionDB),
    invslot = (function()
      local function getCooldown()
        return _G.GetInventoryItemCooldown('player', action.invslot)
      end
      local function update()
        local item = GetInventoryItemID('player', action.invslot)
        button.icon:SetTexture(item and GetItemIcon(item) or 136528)
        if item and _G.GetItemSpell(item) then
          button:Enable(true)
          button.icon:SetVertexColor(1.0, 1.0, 1.0)
        else
          button:Disable()
          button.icon:SetVertexColor(0.4, 0.4, 0.4)
        end
        updateCooldown(button, getCooldown)
      end
      return {
        getCooldown = getCooldown,
        handlers = {
          PLAYER_EQUIPMENT_CHANGED = update,
        },
        init = function()
          button:SetAttribute('macrotext', '/use ' .. action.invslot)
          update()
        end,
        setTooltip = function()
          local item = GetInventoryItemID('player', action.invslot)
          local spell = item and select(2, _G.GetItemSpell(item))
          if spell and _G.IsShiftKeyDown() then
            GameTooltip:SetSpellByID(spell)
          else
            GameTooltip:SetInventoryItem('player', action.invslot)
          end
        end,
      }
    end)(),
    macro = {
      getCooldown = function() end,
      handlers = {},
      init = function()
        if action.actionText then
          button.Name:SetText(action.actionText)
        end
        button.icon:SetTexture(action.texture)
        button:SetAttribute('macrotext', action.macro)
      end,
      setTooltip = function()
        GameTooltip:SetText(action.tooltip)
      end,
    },
    mount = (function()
      local spells = {23214, 13819}
      local items = {8631, 8595, 8563, 13321, 18778}
      local tooltipFn
      local function updateMacro(text)
        if not InCombatLockdown() then
          button:SetAttribute('macrotext', '/stand\n/cancelform\n' .. text)
        end
      end
      local function update()
        for _, spell in ipairs(spells) do
          if IsSpellKnown(spell) then
            updateMacro('/cast ' .. GetSpellInfo(spell))
            button:Enable()
            button.icon:SetVertexColor(1.0, 1.0, 1.0)
            button.icon:SetTexture(GetSpellTexture(spell))
            tooltipFn = function()
              GameTooltip:SetSpellByID(spell)
            end
            return
          end
        end
        for _, item in ipairs(items) do
          if GetItemCount(item) > 0 then
            updateMacro('/use item:' .. item)
            button:Enable()
            button.icon:SetVertexColor(1.0, 1.0, 1.0)
            button.icon:SetTexture(GetItemIcon(item))
            tooltipFn = function()
              GameTooltip:SetHyperlink('item:' .. item)
            end
            return
          end
        end
        updateMacro('')
        button:Disable()
        button.icon:SetVertexColor(0.4, 0.4, 0.4)
        button.icon:SetTexture(132261)
        tooltipFn = function()
          GameTooltip:SetText('No mount... yet.')
        end
      end
      return {
        getCooldown = getGcdCooldown,
        handlers = {
          BAG_UPDATE_DELAYED = update,
          PLAYER_REGEN_DISABLED = function()
            button:SetAttribute('macrotext', '/dismount')
          end,
          PLAYER_REGEN_ENABLED = update,
          SPELLS_CHANGED = update,
        },
        init = update,
        setTooltip = function()
          tooltipFn()
        end,
      }
    end)(),
  }
end

local function getType(action, types)
  for k, v in pairs(types) do
    if action[k] then
      return v
    end
  end
end

local function makeCustomActionButton(i, action)
  local button = CreateFrame(
      'CheckButton', prefix .. i, header, 'ActionButtonTemplate, SecureActionButtonTemplate')
  local ty = getType(action, customTypes(button, action))
  button:SetAttribute('type', 'macro')
  button.HotKey:SetFont(button.HotKey:GetFont(), 13, 'OUTLINE')
  button.HotKey:SetVertexColor(0.75, 0.75, 0.75)
  button.HotKey:SetPoint('TOPLEFT', button, 'TOPLEFT', -2, -4)
  button.Count:SetFont(button.Count:GetFont(), 16, 'OUTLINE')
  button:SetNormalTexture('Interface\\Buttons\\UI-Quickslot2')
  button.NormalTexture:SetTexCoord(0, 0, 0, 0)
  button.cooldown:SetSwipeColor(0, 0, 0)
  ty.init()
  button:SetScript('OnEnter', function()
    GameTooltip_SetDefaultAnchor(GameTooltip, button)
    ty.setTooltip()
  end)
  button:SetScript('OnLeave', function()
    GameTooltip:Hide()
  end)
  button:SetScript('PostClick', function()
    button:SetChecked(false)
  end)
  button:SetScript('OnEvent', (function()
    local handlers = ty.handlers
    for ev in pairs(handlers) do
      button:RegisterEvent(ev)
    end
    return function(_, ev, ...)
      handlers[ev](...)
    end
  end)())
  return button, ty
end

local function makeCustomLabButton(i, action)
  local button = LAB10:CreateButton(i, prefix .. i, header)
  button:SetAttribute('state', 1)
  button:DisableDragNDrop(true)
  Mixin(button, (function()
    local buttonMixin = {}
    for k, v in pairs(labSpell) do
      buttonMixin[k] = function(_, ...)
        return v(action, ...)
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
  local customActionButtons = {}
  for i = 1, 48 do
    local action = actions[i]
    local button, ty = (function()
      if not action then
        local button = CreateFrame('Button', prefix .. i, header, 'ActionButtonTemplate')
        button:Hide()
        return button
      elseif action.spell then
        return makeCustomLabButton(i, action)
      else
        return makeCustomActionButton(i, action)
      end
    end)()
    table.insert(buttons, button)
    customActionButtons[button] = ty
  end
  -- Handle generic events separately from individual button OnEvent handlers.
  G.Eventer({
    SPELL_UPDATE_COOLDOWN = function()
      for button, ty in pairs(customActionButtons) do
        updateCooldown(button, ty.getCooldown)
      end
    end,
    UPDATE_BINDINGS = function()
      for button in pairs(customActionButtons) do
        local key = _G.GetBindingKey('CLICK ' .. button:GetName() .. ':LeftButton')
        if key then
          button.HotKey:SetText(keyBound:ToShortKey(key))
          button.HotKey:Show()
        else
          button.HotKey:Hide()
        end
      end
    end,
  })
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

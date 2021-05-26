local addonName, G = ...

local prefix = addonName .. 'ActionButton'
local header = CreateFrame('Frame', prefix .. 'Header', UIParent, 'SecureHandlerStateTemplate')

local customTypes = (function()
  local function consume(mealDB, potionDB)
    local potionText = (function()
      local s = ''
      for _, consumable in ipairs(potionDB) do
        s = s .. '/use item:' .. consumable[1] .. '\n'
      end
      return s
    end)()
    local currentDB
    local function computeItem(levelarg)
      local level = levelarg or UnitLevel('player')
      for _, consumable in ipairs(currentDB) do
        local item, minlevel = unpack(consumable)
        if level >= minlevel and GetItemCount(item) > 0 then
          return item
        end
      end
      return currentDB[#currentDB][1]  -- give up and return the last thing
    end
    local item
    local function updateItem(level)
      item = computeItem(level)
      return {
        cooldown = { item = item },
        count = { item = item },
        icon = GetItemIcon(item),
        macro = currentDB == potionDB and potionText or ('/use item:' .. item),
        tooltip = { item = item },
      }
    end
    local function updateDB(db)
      currentDB = db
      return updateItem()
    end
    return {
      handlers = {
        BAG_UPDATE_DELAYED = function()
          return updateItem()
        end,
        PLAYER_LEVEL_UP = function(_, level)
          return updateItem(level)
        end,
        PLAYER_REGEN_DISABLED = function()
          return updateDB(potionDB)
        end,
        PLAYER_REGEN_ENABLED = function()
          return updateDB(mealDB)
        end,
      },
      init = function()
        return updateDB(mealDB)
      end,
    }
  end
  return {
    buff = {
      init = function(action)
        return {
          count = action.reagent and { item = action.reagent },
          icon = 135938,
          macro = '/click ' .. addonName .. 'BuffButton',
          tooltip = { text = 'Buff' },
        }
      end,
    },
    drink = consume(G.DrinkDB, G.ManaPotionDB),
    eat = consume(G.FoodDB, G.HealthPotionDB),
    invslot = (function()
      local function update(action)
        return {
          cooldown = { invslot = action.invslot },
          icon = GetInventoryItemTexture('player', action.invslot) or 136528,
          macro = '/use ' .. action.invslot,
          tooltip = { invslot = action.invslot },
        }
      end
      return {
        handlers = {
          PLAYER_EQUIPMENT_CHANGED = update,
        },
        init = update,
      }
    end)(),
    macro = {
      init = function(action)
        return {
          name = action.actionText,
          icon = action.texture,
          macro = action.macro,
          tooltip = { text = action.tooltip },
        }
      end,
    },
    mount = (function()
      local function update()
        for _, spellx in ipairs(G.MountSpellDB) do
          local spell = spellx[1]
          if IsSpellKnown(spell) then
            return {
              cooldown = { spell = spell },
              color = 1.0,
              icon = GetSpellTexture(spell),
              macro = '/cast ' .. GetSpellInfo(spell),
              tooltip = { spell = spell },
            }
          end
        end
        for _, itemx in ipairs(G.MountItemDB) do
          local item = itemx[1]
          if GetItemCount(item) > 0 then
            return {
              cooldown = { item = item },
              color = 1.0,
              icon = GetItemIcon(item),
              macro = '/use item:' .. item,
              tooltip = { item = item },
            }
          end
        end
        return {
          color = 0.4,
          icon = 132261,
          macro = '',
          tooltip = { text = 'No mount... yet.' },
        }
      end
      return {
        handlers = {
          BAG_UPDATE_DELAYED = update,
          PLAYER_REGEN_DISABLED = function()
            return { macro = '/dismount' }
          end,
          PLAYER_REGEN_ENABLED = update,
          SPELLS_CHANGED = update,
        },
        init = update,
      }
    end)(),
    spell = {
      init = function(action)
        local fullName = action.spell .. (action.rank and ('(Rank ' .. action.rank .. ')') or '')
        return {
          cooldown = { spell = fullName },
          count = { spell = fullName },
          -- Use the spell base name for GetSpellTexture; more likely to work on login.
          icon = GetSpellTexture(action.spell),
          macro = (
            '/dismount\n/stand\n'..
            (action.stopcasting and '/stopcasting\n' or '')..
            '/cast'..(action.mouseover and ' [@mouseover,help,nodead][] ' or ' ')..
            fullName),
          name = action.actionText,
          tooltip = { spell = fullName },
          update = { spell = fullName },
        }
      end,
    },
    stopcasting = {
      init = function()
        return {
          icon = 135768,
          macro = '/stopcasting',
          name = 'Stop',
          tooltip = { text = 'Stop Casting' },
        }
      end,
    },
  }
end)()

local function getType(action)
  -- spell > stopcasting
  if action.spell then
    return customTypes.spell
  end
  for k, v in pairs(customTypes) do
    if action[k] then
      return v
    end
  end
end

local cooldownLang = {
  invslot = function(invslot)
    return GetInventoryItemCooldown('player', invslot)
  end,
  item = function(item)
    return GetItemCooldown(item)
  end,
  spell = function(spell)
    return GetSpellCooldown(spell)
  end,
}

local cooldownData = {}

local countLang = {
  item = function(item)
    return GetItemCount(item)
  end,
  spell = function(spell)
    local libCount = LibStub('LibClassicSpellActionCount-1.0')
    return libCount:GetSpellReagentCount(spell)
  end,
}

local countData = {}

local tooltipLang = {
  invslot = function(invslot)
    GameTooltip:SetInventoryItem('player', invslot)
  end,
  item = function(item)
    GameTooltip:SetHyperlink('item:' .. item)
  end,
  spell = function(spell)
    if type(spell) == 'string' then
      spell = select(7, GetSpellInfo(spell))
    end
    GameTooltip:SetSpellByID(spell)
    local subtext = GetSpellSubtext(spell)
    if subtext then
      GameTooltipTextRight1:SetText(subtext)
      GameTooltipTextRight1:SetTextColor(0.5, 0.5, 0.5)
      GameTooltipTextRight1:Show()
      GameTooltip:Show()
    end
  end,
  text = function(text)
    GameTooltip:SetText(text)
  end,
}

local tooltipData = {}

local updateLang = {
  spell = function(spell)
    if IsSpellInRange(spell, 'target') == 0 then
      return 0.8, 0.1, 0.1
    end
    local isUsable, notEnoughMana = IsUsableSpell(spell)
    if isUsable then
      return 1.0, 1.0, 1.0
    elseif notEnoughMana then
      return 0.5, 0.5, 1.0
    else
      return 0.4, 0.4, 0.4
    end
  end,
}

local updateData = {}

local buttonLang = {
  color = function(button, color)
    button.icon:SetVertexColor(color, color, color)
  end,
  cooldown = function(button, cooldown)
    cooldownData[button] = cooldown
    -- hack to update now
    local k, v = next(cooldown)
    local start, duration, enable, modRate = cooldownLang[k](v)
    CooldownFrame_Set(button.cooldown, start, duration, enable, false, modRate)
  end,
  count = function(button, countProgram)
    countData[button] = countProgram
    -- hack to update now
    local k, v = next(countProgram)
    local count = countLang[k](v)
    button.Count:SetText(count == nil and '' or count > 9999 and '*' or count)
  end,
  icon = function(button, icon)
    button.icon:SetTexture(icon)
  end,
  macro = function(button, macro)
    if not InCombatLockdown() then
      button:SetAttribute('macrotext', macro)
    end
  end,
  name = function(button, name)
    button.Name:SetText(name)
  end,
  tooltip = function(button, tooltip)
    tooltipData[button] = tooltip
  end,
  update = function(button, update)
    updateData[button] = update
  end,
}

local function buttonUpdater(buttons)
  local actionUpdate
  local doUpdate = function(self)
    for k, v in pairs(actionUpdate) do
      buttonLang[k](self, v)
    end
  end
  for _, button in pairs(buttons) do
    button.DoUpdate = doUpdate
  end
  return function(i, arg)
    actionUpdate = arg
    header:Execute(([=[
      local buttonid = actions['%d']
      if buttonid then buttons[buttonid]:CallMethod('DoUpdate') end
    ]=]):format(i))
  end
end

local function makeCustomActionButton(i)
  local button = CreateFrame(
      'CheckButton', prefix .. i, header, 'ActionButtonTemplate, SecureActionButtonTemplate')
  button:SetAttribute('type', 'macro')
  button:SetMotionScriptsWhileDisabled(true)
  button.HotKey:SetFont(button.HotKey:GetFont(), 13, 'OUTLINE')
  button.HotKey:SetVertexColor(0.75, 0.75, 0.75)
  button.HotKey:SetPoint('TOPLEFT', button, 'TOPLEFT', -2, -4)
  button.Count:SetFont(button.Count:GetFont(), 16, 'OUTLINE')
  button:SetNormalTexture('Interface\\Buttons\\UI-Quickslot2')
  button.NormalTexture:SetTexCoord(0, 0, 0, 0)
  button.cooldown:SetSwipeColor(0, 0, 0)
  button:SetScript('OnEnter', function()
    GameTooltip_SetDefaultAnchor(GameTooltip, button)
    local tt = tooltipData[button]
    if tt then
      local k, v = next(tt)
      tooltipLang[k](v)
    end
  end)
  button:SetScript('OnLeave', function()
    GameTooltip:Hide()
  end)
  button:SetScript('PostClick', function()
    button:SetChecked(false)
  end)
  button:RegisterEvent('UPDATE_BINDINGS')
  button:SetScript('OnEvent', function(self)
    local key = GetBindingKey('CLICK ' .. self:GetName() .. ':LeftButton')
    if key then
      self.HotKey:SetText(LibStub('LibKeyBound-1.0'):ToShortKey(key))
      self.HotKey:Show()
    else
      self.HotKey:Hide()
    end
  end)
  return button
end

local function makeCustomActionButtons(actions)
  local buttons = {}
  for i = 1, 48 do
    table.insert(buttons, makeCustomActionButton(i))
  end
  header:Execute('buttons = newtable()')
  for i, button in ipairs(buttons) do
    header:SetFrameRef('tmp', button)
    header:Execute(('buttons[%d] = owner:GetFrameRef("tmp")'):format(i))
  end
  header:Execute('actions = newtable()')
  for k in pairs(actions) do
    -- This is where we assume that action numbers are the same as button numbers.
    header:Execute(('actions["%d"] = %d'):format(k, k))
  end
  local handlers = {}
  local function addHandler(ev, handler)
    handlers[ev] = handlers[ev] or {}
    table.insert(handlers[ev], handler)
  end
  local updateButton = buttonUpdater(buttons)
  for i, button in ipairs(buttons) do
    local action = actions[i]
    if not action then
      button:Hide()
    else
      local ty = getType(action)
      updateButton(i, ty.init(action))
      for ev, handler in pairs(ty.handlers or {}) do
        addHandler(ev, function(...)
          return updateButton(i, handler(action, ...))
        end)
      end
    end
  end
  local genericHandlers = {
    BAG_UPDATE_DELAYED = function()
      for button, cd in pairs(countData) do
        local k, v = next(cd)
        local count = countLang[k](v)
        button.Count:SetText(count == nil and '' or count > 9999 and '*' or count)
      end
    end,
    SPELL_UPDATE_COOLDOWN = function()
      for button, cd in pairs(cooldownData) do
        local k, v = next(cd)
        local start, duration, enable, modRate = cooldownLang[k](v)
        CooldownFrame_Set(button.cooldown, start, duration, enable, false, modRate)
      end
    end,
  }
  for ev, handler in pairs(genericHandlers) do
    addHandler(ev, handler)
  end
  local handlersHandlers = {}
  for ev, hs in pairs(handlers) do
    handlersHandlers[ev] = function(...)
      for _, h in ipairs(hs) do
        h(...)
      end
    end
  end
  G.Eventer(handlersHandlers)
  local updateTimer = -1
  CreateFrame('Frame'):SetScript('OnUpdate', function(_, elapsed)
    updateTimer = updateTimer - elapsed
    if updateTimer <= 0 then
      updateTimer = TOOLTIP_UPDATE_TIME
      for button, update in pairs(updateData) do
        local k, v = next(update)
        local r, g, b = updateLang[k](v)
        button.icon:SetVertexColor(r, g, b)
      end
    end
  end)
  return buttons
end

local function makeOnlyLabButtons()
  local LAB10 = LibStub('LibActionButton-1.0')
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

local function makeButtons()
  local charName = UnitName('player')..'-'..GetRealmName()
  local actions = G.Characters[charName]
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
    makeButtons()
  end,
})

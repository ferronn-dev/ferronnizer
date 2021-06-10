local addonName, G = ...

local prefix = addonName .. 'ActionButton'
local header = CreateFrame('Frame', prefix .. 'Header', UIParent, 'SecureHandlerBaseTemplate')

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
        attr = currentDB == potionDB and potionText or ('/use item:' .. item),
        cooldown = { item = item },
        count = { item = item },
        icon = GetItemIcon(item),
        tooltip = { item = item },
      }
    end
    local function updateDB(db)
      currentDB = db
      return updateItem()
    end
    return function()
      return updateDB(mealDB), {
        BAG_UPDATE_DELAYED = function()
          return updateItem()
        end,
        PLAYER_LEVEL_UP = function(level)
          return updateItem(level)
        end,
        PLAYER_REGEN_DISABLED = function()
          return updateDB(potionDB)
        end,
        PLAYER_REGEN_ENABLED = function()
          return updateDB(mealDB)
        end,
      }
    end
  end
  return {
    action = function(action)
      local num = action.action
      local function update()
        return {
          attr = HasAction(num) and num or '',
          icon = GetActionTexture(num),
          name = GetActionText(num),
        }
      end
      local init = Mixin(update(), {
        cooldown = { action = num },
        count = { action = num },
        tooltip = { action = num },
      })
      return init, {
        ACTIONBAR_SLOT_CHANGED = function(slot)
          return slot == num and update() or {}
        end,
      }
    end,
    buff = function(action)
      return {
        attr = '/click ' .. addonName .. 'BuffButton',
        count = action.reagent and { item = action.reagent },
        icon = 135938,
        tooltip = { text = 'Buff' },
      }
    end,
    drink = consume(G.DrinkDB, G.ManaPotionDB),
    eat = consume(G.FoodDB, G.HealthPotionDB),
    invslot = function(action)
      local slot = action.invslot
      local function update()
        local item = GetInventoryItemID('player', slot)
        return {
          attr = item and ('/use ' .. slot) or '',
          color = item and IsUsableItem(item) and 1.0 or 0.4,
          cooldown = item and { item = item } or nil,
          icon = item and GetItemIcon(item) or nil,
          tooltip = item and { item = item } or nil,
        }
      end
      return update(), { PLAYER_EQUIPMENT_CHANGED = update }
    end,
    macro = function(action)
      return {
        attr = action.macro,
        icon = action.texture,
        name = action.actionText,
        tooltip = { text = action.tooltip },
      }
    end,
    mount = function()
      local function update()
        for _, spellx in ipairs(G.MountSpellDB) do
          local spell = spellx[1]
          if IsSpellKnown(spell) then
            return {
              attr = '/cast ' .. GetSpellInfo(spell),
              cooldown = { spell = spell },
              icon = GetSpellTexture(spell),
              tooltip = { spell = spell },
            }
          end
        end
        for _, itemx in ipairs(G.MountItemDB) do
          local item = itemx[1]
          if GetItemCount(item) > 0 then
            return {
              attr = '/use item:' .. item,
              cooldown = { item = item },
              icon = GetItemIcon(item),
              tooltip = { item = item },
            }
          end
        end
        return {
          attr = '',
          icon = 132261,
          tooltip = { text = 'No mount... yet.' },
        }
      end
      return update(), {
        BAG_UPDATE_DELAYED = update,
        PLAYER_REGEN_DISABLED = function()
          return { attr = '/dismount' }
        end,
        PLAYER_REGEN_ENABLED = update,
        SPELLS_CHANGED = update,
      }
    end,
    page = function(action)
      return {
        attr = '#page:' .. action.page,
        count = action.reagent and { item = action.reagent },
        icon = action.texture,
        name = action.actionText,
        tooltip = action.tooltip and { text = action.tooltip },
      }
    end,
    spell = function(action)
      local fullName = action.spell .. (action.rank and ('(Rank ' .. action.rank .. ')') or '')
      local function update()
        local spellid = select(7, GetSpellInfo(action.spell, action.rank and ('Rank ' .. action.rank) or nil))
        return {
          attr = spellid and IsSpellKnown(spellid) and (
            (action.dismount ~= false and '/dismount\n' or '')..
            (action.stand ~= false and '/stand\n' or '')..
            (action.stopcasting and '/stopcasting\n' or '')..
            '/cast'..(action.mouseover and ' [@mouseover,help,nodead][] ' or ' ')..
            fullName) or '',
        }
      end
      local init = Mixin(update(), {
        cooldown = { spell = fullName },
        count = { spell = fullName },
        -- Use the spell base name for GetSpellTexture; more likely to work on login.
        icon = GetSpellTexture(action.spell),
        name = action.actionText,
        tooltip = { spell = fullName },
        update = { spell = fullName },
      })
      return init, { SPELLS_CHANGED = update }
    end,
  }
end)()

local function getType(action)
  for k, v in pairs(customTypes) do
    if action[k] then
      return v(action)
    end
  end
end

local pendingAttrs = {}

local function updateAttr(actionid, attr)
  header:SetAttribute('tmp', attr)
  header:Execute(([[self:RunAttribute('updateActionAttr', '%s', self:GetAttribute('tmp'))]]):format(actionid))
end

local updateButton = (function()
  local lang = {
    color = function(button, color)
      button.icon:SetVertexColor(color, color, color)
    end,
    cooldown = (function()
      local cooldownLang = {
        action = function(action)
          return GetActionCooldown(action)
        end,
        item = function(item)
          return GetItemCooldown(item)
        end,
        reset = function()
          return 0, 0, 0
        end,
        spell = function(spell)
          return GetSpellCooldown(spell)
        end,
      }
      return function(button, prog)
        local k, v = next(prog)
        local start, duration, enable, modRate = cooldownLang[k](v)
        CooldownFrame_Set(button.cooldown, start, duration, enable, false, modRate)
      end
    end)(),
    count = (function()
      local countLang = {
        action = function(action)
          return IsConsumableAction(action) and GetActionCount(action) or -1
        end,
        item = function(item)
          return GetItemCount(item)
        end,
        reset = function()
          return -1
        end,
        spell = function(spell)
          return IsConsumableSpell(spell) and GetSpellCount(spell) or -1
        end,
      }
      return function(button, prog)
        local k, v = next(prog)
        local count = countLang[k](v)
        button.Count:SetText(count < 0 and '' or count > 9999 and '*' or count)
      end
    end)(),
    icon = function(button, icon)
      button.icon:SetTexture(icon)
    end,
    name = function(button, name)
      button.Name:SetText(name)
    end,
    tooltip = (function()
      local tooltipLang = {
        action = function(action)
          GameTooltip:SetAction(action)
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
      return function(button, tooltip)
        local k, v = next(tooltip)
        local fn = tooltipLang[k]
        button.ttfn = fn and function() fn(v) end or nil
      end
    end)(),
    update = (function()
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
      return function(button, prog)
        local k, v = next(prog)
        button.icon:SetVertexColor(updateLang[k](v))
      end
    end)(),
  }
  return function(button, update)
    if button then
      for k, v in pairs(update) do
        lang[k](button, v)
      end
    end
  end
end)()

local actionButtons = {}
local actionButtonState = {}

local updateAction = (function()
  local lang = {
    attr = function(attr, actionid)
      if InCombatLockdown() then
        pendingAttrs[actionid] = attr
      else
        updateAttr(actionid, attr)
      end
    end,
    color = function(color)
      return { color = color }
    end,
    cooldown = function(cooldown)
      return { cooldown = cooldown }
    end,
    count = function(count)
      return { count = count }
    end,
    icon = function(icon)
      return { icon = icon }
    end,
    name = function(name)
      return { name = name }
    end,
    tooltip = function(tooltip)
      return { tooltip = tooltip }
    end,
    update = function(update)
      return { update = update }
    end,
  }
  return function(actionid, update)
    local buttonUpdate = {}
    for k, v in pairs(update) do
      Mixin(buttonUpdate, lang[k](v, actionid))
    end
    Mixin(actionButtonState[actionid], buttonUpdate)
    updateButton(actionButtons[actionid], buttonUpdate)
  end
end)()

local function setupActionState(actions)
  local handlers = {}
  local function addHandler(ev, handler)
    handlers[ev] = handlers[ev] or {}
    table.insert(handlers[ev], handler)
  end
  for actionid in pairs(actions) do
    actionButtonState[actionid] = {}
  end
  for actionid, action in pairs(actions) do
    local init, tyhandlers = getType(action)
    updateAction(actionid, init)
    for ev, handler in pairs(tyhandlers or {}) do
      addHandler(ev, function(...)
        return updateAction(actionid, handler(...))
      end)
    end
  end
  local function updateHandler(name)
    return function()
      for actionid, state in pairs(actionButtonState) do
        if state[name] then
          updateButton(actionButtons[actionid], { [name] = state[name] })
        end
      end
    end
  end
  local genericHandlers = {
    BAG_UPDATE_DELAYED = updateHandler('count'),
    SPELL_UPDATE_COOLDOWN = updateHandler('cooldown'),
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
  -- Run post-combat attr updates before delivering messages to actions.
  -- These happened earlier in time.
  local postCombatHandler = handlersHandlers.PLAYER_REGEN_ENABLED
  handlersHandlers.PLAYER_REGEN_ENABLED = function(...)
    for actionid, attr in pairs(pendingAttrs) do
      updateAttr(actionid, attr)
    end
    wipe(pendingAttrs)
    return postCombatHandler and postCombatHandler(...)
  end
  G.Eventer(handlersHandlers)
  G.Updater(TOOLTIP_UPDATE_TIME, updateHandler('update'))
end

local function makeActions()
  local actions = {}
  local charActions = G.Characters[UnitName('player')..'-'..GetRealmName()]
  if charActions then
    for i, v in pairs(charActions) do
      if v.page then
        local pageName = 'fraction' .. i .. 'x'
        actions['fraction' .. i] = Mixin({}, v, { page = pageName })
        for j, x in pairs(v.page) do
          actions[pageName .. j] = x
        end
      elseif v.stopcasting and not v.spell then
        actions['fraction' .. i] = {
          actionText = 'Stop',
          macro = '/stopcasting',
          texture = 135768,
          tooltip = 'Stop Casting',
        }
      else
        actions['fraction' .. i] = v
      end
    end
  else
    for i = 1, 48 do
      actions['fraction' .. i] = { action = i }
    end
  end
  local professions = {
    'Alchemy',
    'Cooking',
    'Disenchant',
    'Enchanting',
    'First Aid',
    'Engineering',
    'Tailoring',
    'Smelting',
    'Leatherworking',
    'Blacksmithing',
  }
  for i, spell in ipairs(professions) do
    actions['profession' .. i] = {
      dismount = false,
      spell = spell,
      stand = false,
    }
  end
  return actions
end

local function makeButtons()
  local scripts = {
    OnEnter = function(self)
      if self.ttfn then
        GameTooltip_SetDefaultAnchor(GameTooltip, self)
        self.ttfn()
      end
    end,
    OnEvent = function(self)
      local key = GetBindingKey('CLICK ' .. self:GetName() .. ':LeftButton')
      if key then
        self.HotKey:SetText(LibStub('LibKeyBound-1.0'):ToShortKey(key))
        self.HotKey:Show()
      else
        self.HotKey:Hide()
      end
    end,
    OnLeave = function()
      GameTooltip:Hide()
    end,
    PostClick = function(self)
      self:SetChecked(false)
    end,
  }
  local insecureRefresh = function(self, actionid, prevActionID)
    if prevActionID then
      actionButtons[prevActionID] = nil
    end
    actionButtons[actionid] = self
    local reset = {
      color = 1.0,
      cooldown = { reset = true },
      count = { reset = true },
      icon = 136235,  -- samwise
      name = '',
      tooltip = { reset = true },
    }
    updateButton(self, Mixin(reset, actionButtonState[actionid]))
  end
  local setFraction = [=[
    local actionid, value = ...
    local type_, action, macrotext
    if type(value) == 'string' then
      type_, macrotext = 'macro', value
    elseif value ~= nil then
      type_, action = 'action', value
    end
    local prevActionID = self:GetAttribute('fraction')
    self:SetAttribute('fraction', actionid)
    self:SetAttribute('type', type_)
    self:SetAttribute('action', action)
    self:SetAttribute('macrotext', macrotext)
    if actionid and macrotext ~= '' then
      self:CallMethod('Refresh', actionid, prevActionID)
      self:Show()
    else
      self:Hide()
    end
  ]=]
  local makeButton = function(i)
    local button = CreateFrame(
      'CheckButton', prefix .. i, header, 'ActionButtonTemplate, SecureActionButtonTemplate')
    button:SetMotionScriptsWhileDisabled(true)
    button.HotKey:SetFont(button.HotKey:GetFont(), 13, 'OUTLINE')
    button.HotKey:SetVertexColor(0.75, 0.75, 0.75)
    button.HotKey:SetPoint('TOPLEFT', button, 'TOPLEFT', -2, -4)
    button.Count:SetFont(button.Count:GetFont(), 16, 'OUTLINE')
    button:SetNormalTexture('Interface\\Buttons\\UI-Quickslot2')
    button.NormalTexture:SetTexCoord(0, 0, 0, 0)
    button.cooldown:SetSwipeColor(0, 0, 0)
    button:RegisterEvent('UPDATE_BINDINGS')
    for k, v in pairs(scripts) do
      button:SetScript(k, v)
    end
    button.Refresh = insecureRefresh
    button:SetAttribute('setFraction', setFraction)
    button:Hide()
    return button
  end
  local buttons = {}
  for i = 1, 48 do
    table.insert(buttons, makeButton(i))
  end
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
  return buttons
end

local function setupHeader(buttons)
  header:Execute([[
    buttons = newtable()
    actionToButton = newtable()
    actionAttrs = newtable()
  ]])
  for i, button in ipairs(buttons) do
    header:SetFrameRef('tmp', button)
    header:Execute(([[buttons[%d] = self:GetFrameRef('tmp')]]):format(i))
  end
  header:SetAttribute('updateActionAttr', [=[
    local actionid, value = ...
    actionAttrs[actionid] = value
    local buttonid = actionToButton[actionid]
    if buttonid then
      buttons[buttonid]:RunAttribute('setFraction', actionid, value)
    end
  ]=])
  header:SetAttribute('updateActionPage', [=[
    local page = ...
    if currentPage ~= page then
      currentPage = page
      for buttonid, button in ipairs(buttons) do
        local prevActionID = button:GetAttribute('fraction')
        if prevActionID then
          actionToButton[prevActionID] = nil
        end
        local actionid = page .. buttonid
        local attr = actionAttrs[actionid]
        if attr then
          actionToButton[actionid] = buttonid
          button:RunAttribute('setFraction', actionid, attr)
        else
          button:RunAttribute('setFraction', nil, nil)
        end
      end
    end
  ]=])
end

local function setupPaging(buttons)
  header:Execute([[self:RunAttribute('updateActionPage', 'fraction')]])
  for _, button in pairs(buttons) do
    header:WrapScript(button, 'OnClick', 'return nil, true', [=[
      local actionid = self:GetAttribute('fraction')
      local attr = actionid and actionAttrs[actionid] or ''
      local page = type(attr) == 'string' and attr:sub(1, 6) == '#page:' and attr:sub(7) or 'fraction'
      owner:RunAttribute('updateActionPage', page)
    ]=])
  end
  -- Hack to support professions for now.
  local professionsButton = CreateFrame('Button', prefix .. 'ProfessionSwitcher', header, 'SecureActionButtonTemplate')
  SetOverrideBindingClick(header, true, 'CTRL-P', professionsButton:GetName())
  header:WrapScript(professionsButton, 'OnClick', 'return nil, true', [=[
    owner:RunAttribute('updateActionPage', 'profession')
  ]=])
end

local function setupActionButtons()
  local actions = makeActions()
  local buttons = makeButtons()
  setupHeader(buttons)
  setupActionState(actions)
  setupPaging(buttons)
end

G.Eventer({
  PLAYER_LOGIN = function()
    G.ReparentFrame(MainMenuBar)
    setupActionButtons()
  end,
})

local addonName, G = ...

local makeAction = (function()
  local function consume(mealDB, potionDB, nethergon)
    local potionText = (function()
      local s = ''
      for _, consumable in ipairs(potionDB) do
        s = s .. '/use item:' .. consumable[1] .. '\n'
      end
      return s
    end)()
    local nethergonText = '/use item:' .. nethergon .. '\n' .. potionText
    local currentDB
    local function inNethergonZone()
      local id = select(8, GetInstanceInfo())
      return id == 550 or id == 552 or id == 553 or id == 554
    end
    local function computeItem(levelarg)
      local level = levelarg or UnitLevel('player')
      if inNethergonZone() and currentDB == potionDB and level >= 55 and GetItemCount(nethergon) > 0 then
        return nethergon
      end
      for _, consumable in ipairs(currentDB) do
        local item, minlevel = unpack(consumable)
        if level >= minlevel and GetItemCount(item) > 0 then
          return item
        end
      end
      return currentDB[#currentDB][1]  -- give up and return the last thing
    end
    local function computeAttr(item)
      if currentDB == mealDB then
        return '/use item:' .. item
      elseif inNethergonZone() then
        return nethergonText
      else
        return potionText
      end
    end
    local function updateItem(level)
      local item = computeItem(level)
      return {
        attr = computeAttr(item),
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
        PLAYER_ENTERING_WORLD = function()
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
  local lang = {
    action = function(action)
      local num = action.action
      local function update()
        return {
          attr = HasAction(num) and ('#action:' .. num) or '',
          icon = GetActionTexture(num),
          name = GetActionText(num),
        }
      end
      local init = Mixin(update(), {
        cooldown = { action = num },
        count = { action = num },
        tooltip = { action = num },
        update = { action = num },
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
    drink = consume(G.DrinkDB, G.ManaPotionDB, 32902),
    eat = consume(G.FoodDB, G.HealthPotionDB, 32905),
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
      local function getMount(db)
        for _, entry in ipairs(db) do
          local item, spell = unpack(entry)
          if item and GetItemCount(item) > 0 then
            return '/use', 'item:' .. item, {
              cooldown = { item = item },
              icon = GetItemIcon(item),
              tooltip = { item = item },
            }
          elseif IsSpellKnown(spell) then
            return '/cast', (GetSpellInfo(spell)), {
              cooldown = { spell = spell },
              icon = GetSpellTexture(spell),
              tooltip = { spell = spell },
            }
          end
        end
      end
      local function update()
        local gcmd, garg, ground = getMount(G.MountGroundDB)
        local fcmd, farg, flight = getMount(G.MountFlightDB)
        if gcmd and fcmd then
          local macro = (
            string.format('%s [nomounted,flyable] %s\n', fcmd, farg) ..
            string.format('%s [nomounted,noflyable] %s\n', gcmd, garg) ..
            '/dismount [mounted]'
          )
          -- TODO update icon etc to use flight mount based on OnUpdate IsFlyableArea
          return Mixin({ attr = macro }, ground)
        elseif gcmd then
          local macro = string.format('%s [nomounted] %s\n/dismount [mounted]', gcmd, garg)
          return Mixin({ attr = macro }, ground)
        elseif fcmd then
          local macro = string.format('%s [nomounted] %s\n/dismount [mounted]', fcmd, farg)
          return Mixin({ attr = macro }, flight)
        else
          return {
            attr = '',
            icon = 132261,
            tooltip = { text = 'No mount... yet.' },
          }
        end
      end
      return update(), {
        BAG_UPDATE_DELAYED = update,
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
    petaction = function(action)
      local num = action.petaction
      local function update()
        local _, texture, isToken = GetPetActionInfo(num)
        return {
          icon = isToken and _G[texture] or texture or 'Interface\\Buttons\\UI-Quickslot2'
        }
      end
      local init = Mixin(update(), {
        attr = '#petaction:' .. num,
        tooltip = { petaction = num },
      })
      return init, { UNIT_PET = update }
    end,
    spell = function(action)
      local shortName = action.spell
      local rankStr = action.rank and ('Rank ' .. action.rank) or nil
      local fullName = shortName .. (rankStr and ('(' .. rankStr .. ')') or '')
      local macro = (
        (action.dismount ~= false and '/dismount\n' or '')..
        (action.stand ~= false and '/stand\n' or '')..
        (action.stopcasting and '/stopcasting\n' or '')..
        '/cast'..(action.mouseover and ' [@mouseover,help,nodead][] ' or ' ')..
        fullName)
      local function update()
        local spellid = select(7, GetSpellInfo(shortName, rankStr))
        return {
          attr = spellid and IsSpellKnown(spellid) and macro or '',
          -- Use the spell base name for GetSpellTexture; more likely to work on login.
          icon = GetSpellTexture(shortName),
        }
      end
      local init = Mixin(update(), {
        cooldown = { spell = fullName },
        count = { spell = fullName },
        name = action.actionText,
        tooltip = { spell = fullName },
        update = { spell = fullName },
      })
      return init, { SPELLS_CHANGED = update }
    end,
  }
  return function(action)
    for k, v in pairs(lang) do
      if action[k] then
        return v(action)
      end
    end
  end
end)()

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
        button.Count:SetText(count < 0 and '' or count > 9999 and '*' or tostring(count))
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
        petaction = function(petaction)
          GameTooltip:SetPetAction(petaction)
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
      local function updateColor(isFooInRange, isUsableFoo)
        local function getColor(foo)
          if isFooInRange(foo, 'target') == 0 then
            return 0.8, 0.1, 0.1
          end
          local isUsable, notEnoughMana = isUsableFoo(foo)
          if isUsable then
            return 1.0, 1.0, 1.0
          elseif notEnoughMana then
            return 0.5, 0.5, 1.0
          else
            return 0.4, 0.4, 0.4
          end
        end
        return function(foo, button)
          button.icon:SetVertexColor(getColor(foo))
        end
      end
      local updateLang = {
        action = updateColor(IsActionInRange, IsUsableAction),
        spell = updateColor(IsSpellInRange, IsUsableSpell),
      }
      return function(button, prog)
        local k, v = next(prog)
        updateLang[k](v, button)
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

local newButton, updateAttr = (function()
  local prefix = addonName .. 'ActionButton'
  local header = CreateFrame('Frame', prefix .. 'Header', UIParent, 'SecureHandlerStateTemplate')
  header:Execute([[
    buttons = newtable()
    actionToButton = newtable()
    actionAttrs = newtable()
    currentPage = 'invalid'
    setFraction = [=[
      local actionid, value = ...
      local type_, action, macrotext
      if value:sub(1, 8) == '#action:' then
        type_, action = 'action', tonumber(value:sub(9))
      elseif value:sub(1, 11) == '#petaction:' then
        type_, action = 'pet', tonumber(value:sub(12))
      else
        type_, macrotext = 'macro', value
      end
      self:SetAttribute('type', type_)
      self:SetAttribute('action', action)
      self:SetAttribute('macrotext', macrotext)
      if actionid and macrotext ~= '' then
        self:CallMethod('Refresh', actionid)
        self:Show()
      else
        self:Hide()
      end
    ]=]
    updateActionAttr = [=[
      local actionid, value = ...
      actionAttrs[actionid] = value
      local buttonid = actionToButton[actionid]
      if buttonid then
        self:RunFor(buttons[buttonid], setFraction, actionid, value)
      end
    ]=]
    updateActionPage = [=[
      local page = ...
      if currentPage ~= page then
        local previousPage = currentPage
        currentPage = page
        self:CallMethod('InsecureUpdateActionPage', currentPage, previousPage)
        for buttonid, button in ipairs(buttons) do
          actionToButton[previousPage .. buttonid] = nil
          local actionid = page .. buttonid
          local attr = actionAttrs[actionid]
          if attr then
            actionToButton[actionid] = buttonid
            self:RunFor(button, setFraction, actionid, attr)
          else
            self:RunFor(button, setFraction, nil, '')
          end
        end
      end
    ]=]
    updatePageOnClick = [=[
      if currentPage ~= 'pet' then
        local buttonid = ...
        local attr = actionAttrs[currentPage .. buttonid] or ''
        local page = attr:sub(1, 6) == '#page:' and attr:sub(7) or 'fraction'
        self:Run(updateActionPage, page)
      end
    ]=]
  ]])

  RegisterAttributeDriver(header, 'state-petexists', '[@pet,exists] true; false')
  header:SetAttribute('_onstate-petexists', [=[
    -- If we just got a pet and it's not a hunter/warlock pet, switch to the pet page.
    -- If we just lost a pet and we're on the pet page, go back to the fraction page.
    local petExists = newstate == 'true'
    local creatureFamily, petName = PlayerPetSummary()
    if petExists and not creatureFamily and petName ~= 'Shadowfiend' then
      owner:Run(updateActionPage, 'pet')
    elseif not petExists and currentPage == 'pet' then
      owner:Run(updateActionPage, 'fraction')
    end
  ]=])

  header:RegisterEvent('PLAYER_ENTERING_WORLD')
  header:SetScript('OnEvent', function(self)
    self:Execute([[self:Run(updateActionPage, 'fraction')]])
  end)

  local switchers = {
    emotes = 'Emote',
    pet = 'Pet',
    profession = 'Profession',
  }
  for k, v in pairs(switchers) do
    local switch = CreateFrame('Button', prefix .. v .. 'Switcher', header, 'SecureActionButtonTemplate')
    header:WrapScript(switch, 'OnClick', 'return nil, true', ([=[
      local page = '%s'
      owner:Run(updateActionPage, currentPage == page and 'fraction' or page)
    ]=]):format(k))
  end

  local insecureRefresh = function(self, actionid)
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

  local buttons = {}

  header.InsecureUpdateActionPage = function(_, newPage, prevPage)
    for i, button in ipairs(buttons) do
      actionButtons[prevPage .. i] = nil
      actionButtons[newPage .. i] = button
    end
  end

  local num = 0
  local function newButton()
    num = num + 1
    local button = CreateFrame(
      'CheckButton', prefix .. num, header, 'ActionButtonTemplate, SecureActionButtonTemplate')
    header:WrapScript(button, 'OnClick', 'return nil, true', ([[
      owner:Run(updatePageOnClick, %d)
    ]]):format(num))
    header:SetFrameRef('tmp', button)
    header:Execute([[tinsert(buttons, self:GetFrameRef('tmp'))]])
    button.Refresh = insecureRefresh
    table.insert(buttons, button)
    return button
  end

  local function updateAttr(actionid, attr)
    header:Execute(([[self:Run(updateActionAttr, '%s', [==[%s]==])]]):format(actionid, attr))
  end

  return newButton, updateAttr
end)()

local maybeSetAttr, drainPendingAttrs = (function()
  local pendingAttrs = {}
  local function maybeSetAttr(actionid, attr)
    if InCombatLockdown() then
      pendingAttrs[actionid] = attr
    else
      updateAttr(actionid, attr)
    end
  end
  local function drainPendingAttrs()
    for actionid, attr in pairs(pendingAttrs) do
      updateAttr(actionid, attr)
    end
    wipe(pendingAttrs)
  end
  return maybeSetAttr, drainPendingAttrs
end)()

local function updateAction(actionid, update)
  if update.attr then
    maybeSetAttr(actionid, update.attr)
    update.attr = nil
  end
  Mixin(actionButtonState[actionid], update)
  updateButton(actionButtons[actionid], update)
end

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
    local init, tyhandlers = makeAction(action)
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
    drainPendingAttrs()
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
  for i = 1, NUM_PET_ACTION_SLOTS do
    actions['pet' .. i] = { petaction = i }
  end
  actions['pet' .. (NUM_PET_ACTION_SLOTS + 1)] = {
    macro = '/cancelaura Mind Control',
    texture = 136206,
    tooltip = 'Cancel Mind Control',
  }
  return actions
end

local attachToIconGrid, attachToTextGrid = (function()
  local width, height = 36, 18
  local frames = {}
  for _ = 1, 96 do
    local frame = CreateFrame('Frame')
    frame:SetSize(width, height)
    table.insert(frames, frame)
  end
  for i, frame in ipairs(frames) do
    if i <= 84 then
      frame:SetPoint('BOTTOM', frames[i + 12], 'TOP')
    end
    if (i - 1) % 12 < 5 then
      frame:SetPoint('RIGHT', frames[i + 1], 'LEFT')
    elseif (i - 1) % 12 > 6 then
      frame:SetPoint('LEFT', frames[i - 1], 'RIGHT')
    end
  end
  frames[90]:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOM')
  frames[91]:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOM')
  local function icon(frame, row, col)
    local index = (row - 1) * 24 + col
    frame:ClearAllPoints()
    frame:SetPoint('TOPLEFT', frames[index], 'TOPLEFT')
    frame:SetPoint('BOTTOMRIGHT', frames[index + 12], 'BOTTOMRIGHT')
  end
  local function text(frame, row, col)
    local index = (row - 1) * 12 + (col - 1) * 2 + 1
    frame:ClearAllPoints()
    frame:SetPoint('TOPLEFT', frames[index], 'TOPLEFT')
    frame:SetPoint('BOTTOMRIGHT', frames[index + 1], 'BOTTOMRIGHT')
  end
  return icon, text
end)()

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
  local makeButton = function(row, col)
    local button = newButton()
    attachToIconGrid(button, row, col)
    button:SetMotionScriptsWhileDisabled(true)
    button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
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
    button:Hide()
    return button
  end
  local buttons = {}
  for row = 1, 4 do
    for col = 1, 12 do
      table.insert(buttons, makeButton(row, col))
    end
  end
  -- TODO wire these up to the header, actions, etc
  local parent = CreateFrame('Frame', addonName .. 'TextButtonParent', UIParent)
  parent:Hide()
  for row = 1, 8 do
    for col = 1, 6 do
      local idx = (row - 1) * 6 + col
      local frame = CreateFrame('Button', addonName .. 'TextButton' .. idx, parent, 'UIPanelButtonTemplate')
      frame.Text:SetText('Action ' .. idx)
      attachToTextGrid(frame, row, col)
    end
  end
  return buttons
end

G.Eventer({
  PLAYER_LOGIN = function()
    G.ReparentFrame(MainMenuBar)
    makeButtons()
    setupActionState(makeActions())
  end,
})

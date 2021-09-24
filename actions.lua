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
        attr = item and computeAttr(item) or nil,
        ui = item and { item = item } or { hide = true },
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
    aura = function(action)
      local index, filter = action.aura.index, action.aura.filter
      local function update(unit)
        if not UnitIsUnit(unit, 'player') then
          return {}
        else
          local _, icon = UnitAura('player', index, filter)
          return {
            alpha = icon and 1.0 or 0.0,
            icon = icon,
          }
        end
      end
      local attr = string.format('#cancelaura:%2d:%s', index, filter)
      return Mixin({ attr = attr }, update('player')), { UNIT_AURA = update }
    end,
    bandage = function()
      local macro = ''
      for _, entry in ipairs(G.BandageDB) do
        macro = macro .. '/use item:' .. entry[1] .. '\n'
      end
      local function currentSkill()
        for i = 1, GetNumSkillLines() do
          local name, _, _, value = GetSkillLineInfo(i)
          if name == PROFESSIONS_FIRST_AID then
            return value
          end
        end
        return 0
      end
      local function currentItem()
        local skill = currentSkill()
        for _, entry in ipairs(G.BandageDB) do
          local item, minskill = unpack(entry)
          if skill >= minskill and GetItemCount(item) > 0 then
            return item
          end
        end
      end
      local function update()
        local item = currentItem()
        return { ui = item and { item = item } or { hide = true } }
      end
      return Mixin(update(), { attr = macro }), {
        BAG_UPDATE_DELAYED = update,
        CHAT_MSG_SKILL = update,
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
    emote = function(action)
      local emote = action.emote
      local keyName = 'CLICK ' .. addonName .. 'ActionButton' .. action.index .. ':LeftButton'
      local function update()
        local key = GetBindingKey(keyName)
        local keystr = key and (LibStub('LibKeyBound-1.0'):ToShortKey(key) .. ' - ') or ''
        return { name = keystr .. emote }
      end
      return Mixin(update(), { attr = '/' .. emote }), { UPDATE_BINDINGS = update }
    end,
    healset = function(action)
      local healset = action.healset
      local spellset = {}
      for _, spell in ipairs(healset.spells) do
        local ranks = G.SpellDB[spell]
        for i, rank in ipairs(ranks) do
          local rn = #ranks - i + 1
          local fullName = ('%s(Rank %d)'):format(spell, rn)
          local actionText = ''
          for w in spell:gmatch('%S+') do
            actionText = actionText .. w:sub(1, 1)
          end
          actionText = actionText .. rn
          table.insert(spellset, {
            action = {
              attr = '/dismount [noflying]\n/stand\n/cast [@mouseover,help,nodead][] ' .. fullName,
              icon = GetSpellTexture(spell),
              name = actionText,
              ui = { spell = fullName },
            },
            id = rank[1],
          })
        end
      end
      local idealpcts = healset.ranks
      local myrank = #idealpcts - action.rank + 1
      local function makeDistance(t, k)
        return function(a, b)
          local aa = math.abs(t[a] - k)
          local bb = math.abs(t[b] - k)
          return aa < bb
        end
      end
      local function update()
        local known = {}
        for i, spell in ipairs(spellset) do
          if IsSpellKnown(spell.id) then
            table.insert(known, i)
          end
        end
        if #known <= #idealpcts then
          local myindex = known[myrank]
          return myindex and spellset[myindex].action or { attr = '' }
        else
          local klo, khi = known[1], known[#known]
          local assignedpcts = {}
          for i, j in ipairs(known) do
            assignedpcts[i] = 1 - (j - klo) / (khi - klo)
          end
          local assigneds = {}
          for i, j in ipairs(assignedpcts) do
            assigneds[i] = makeDistance(idealpcts, j)
          end
          local ideals = {}
          for i, j in ipairs(idealpcts) do
            ideals[i] = makeDistance(assignedpcts, j)
          end
          for assigned, ideal in pairs(G.StableMarriage(ideals, assigneds)) do
            if ideal == myrank then
              return spellset[known[assigned]].action
            end
          end
          -- This shouldn't happen...
          return { attr = '' }
        end
      end
      return update(), { SPELLS_CHANGED = update }
    end,
    invslot = function(action)
      local slot = action.invslot
      local function update()
        local item = GetInventoryItemID('player', slot)
        return not item and { attr = '' } or {
          attr = '/use ' .. slot,
          ui = { item = item },
        }
      end
      return update(), { PLAYER_EQUIPMENT_CHANGED = update }
    end,
    item = function(action)
      return {
        attr = '/use item:' .. action.item,
        ui = { item = action.item },
      }
    end,
    judgement = function(action)
      return {
        attr = '/cast Judgement\n/cast Seal of Righteousness',
        ui = { spell = 'Judgement' },
      }
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
              ui = { item = item },
            }
          elseif IsSpellKnown(spell) then
            return '/cast', (GetSpellInfo(spell)), {
              ui = { spell = spell },
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
          return { attr = '' }
        end
      end
      return update(), {
        BAG_UPDATE_DELAYED = update,
        SPELLS_CHANGED = update,
      }
    end,
    noncombat = function(action)
      local macro = ('/run SelectGossipOption(%d)'):format(action.noncombat)
      local init = {
        attr = '',
        icon = 134400,
      }
      return init, {
        GOSSIP_SHOW = function()
          return { attr = macro }
        end,
        GOSSIP_CLOSED = function()
          return { attr = '' }
        end,
      }
    end,
    oneof = function(action)
      local page, spells = action.oneofpage, action.oneof
      local function update()
        local known = {}
        for _, name in ipairs(spells) do
          local id = select(7, GetSpellInfo(name))
          if id and IsSpellKnown(id) then
            known[id] = true
          end
        end
        if not next(known) then
          return { attr = '' }
        end
        local spell = spells[1]
        for i = 1, 40 do
          local buff = select(10, UnitBuff('player', i))
          if not buff then
            break
          end
          if known[buff] then
            spell = buff
            break
          end
        end
        return { attr = '#page:' .. page, ui = { spell = spell } }
      end
      return {}, {
        SPELLS_CHANGED = update,
        UNIT_AURA = update,
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
        local _, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(num)
        local icon = isToken and _G[texture] or texture
        return {
          alpha = icon and 1.0 or 0.0,
          autocast = autoCastAllowed and (autoCastEnabled and 'enabled' or 'disabled') or 'disallowed',
          checked = { value = isActive or false },
          icon = icon,
        }
      end
      local init = Mixin(update(), {
        attr = '#petaction:' .. num,
        cooldown = { petaction = num },
        tooltip = { petaction = num },
      })
      return init, {
        PET_BAR_UPDATE = update,
        PET_UI_UPDATE = update,
        UNIT_PET = update,
      }
    end,
    shapeshift = function(action)
      local shapes = action.shapeshift
      local macro = '/cast'
      for shape, spell in pairs(shapes) do
        macro = macro .. (' [form:%d] %s;'):format(shape, spell)
      end
      local function update()
        local shape = GetShapeshiftForm()
        local spell = shape and shapes[shape] or nil
        return { ui = spell and { spell = spell } or { hide = true } }
      end
      return { attr = macro }, {
        SPELLS_CHANGED = update,
        UPDATE_SHAPESHIFT_FORM = update,
      }
    end,
    spell = function(action)
      local shortName = action.spell
      local rankStr = action.rank and ('Rank ' .. action.rank) or nil
      local fullName = shortName .. (rankStr and ('(' .. rankStr .. ')') or '')
      local macro = (
        (action.dismount ~= false and '/dismount [noflying]\n' or '')..
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
        count = action.ammo and { invslot = 0 } or { spell = fullName },
        name = action.actionText,
        ui = { spell = fullName },
      })
      return init, { SPELLS_CHANGED = update }
    end,
    spells = function(action)
      local spells = action.spells
      local prefix = (
          (action.stopcasting and '/stopcasting\n' or '')..
          '/cast'..(action.mouseover and ' [@mouseover,help,nodead][] ' or ' '))
      local function update()
        for _, name in ipairs(spells) do
          local id = select(7, GetSpellInfo(name))
          if id and IsSpellKnown(id) then
            return {
              attr = prefix .. name,
              ui = { spell = name },
            }
          end
        end
        return {}
      end
      return {}, { SPELLS_CHANGED = update }
    end,
  }
  return function(action)
    for k, v in pairs(lang) do
      if action[k] then
        return v(action)
      end
    end
    error('invalid action')
  end
end)()

local updateButton = (function()
  local lang = {
    alpha = function(button, alpha)
      button:SetAlpha(alpha)
    end,
    autocast = (function()
      local autocastLang = {
        disabled = function(button)
          button.AutoCastable:Show()
          AutoCastShine_AutoCastStop(button.AutoCastShine)
        end,
        disallowed = function(button)
          button.AutoCastable:Hide()
          AutoCastShine_AutoCastStop(button.AutoCastShine)
        end,
        enabled = function(button)
          button.AutoCastable:Show()
          AutoCastShine_AutoCastStart(button.AutoCastShine)
        end,
      }
      return function(button, autocast)
        if button.AutoCastable then
          assert(autocastLang[autocast], 'invalid autocast ' .. autocast)(button)
        end
      end
    end)(),
    checked = (function()
      local checkedLang = {
        spell = function(spell)
          return IsCurrentSpell(spell)
        end,
        value = function(value)
          return value
        end,
      }
      return function(button, checked)
        if button.SetChecked then
          local k, v = next(checked)
          local fn = assert(checkedLang[k], 'invalid checked program ' .. tostring(k))
          local chfn = function() return fn(v) end
          button:SetChecked(chfn())
          button.chfn = chfn
        end
      end
    end)(),
    color = function(button, color)
      if button.icon then
        button.icon:SetVertexColor(color, color, color)
      end
    end,
    cooldown = (function()
      local cooldownLang = {
        action = function(action)
          return GetActionCooldown(action)
        end,
        item = function(item)
          return GetItemCooldown(item)
        end,
        petaction = function(petaction)
          return GetPetActionCooldown(petaction)
        end,
        reset = function()
          return 0, 0, 0
        end,
        spell = function(spell)
          return GetSpellCooldown(spell)
        end,
      }
      return function(button, prog)
        if button.cooldown then
          local k, v = next(prog)
          local start, duration, enable, modRate = cooldownLang[k](v)
          CooldownFrame_Set(button.cooldown, start, duration, enable, false, modRate)
        end
      end
    end)(),
    count = (function()
      local countLang = {
        action = function(action)
          return IsConsumableAction(action) and GetActionCount(action) or -1
        end,
        invslot = function(invslot)
          return GetInventoryItemCount('player', invslot) or -1
        end,
        item = function(item)
          return GetItemCount(item)
        end,
        spell = function(spell)
          return IsConsumableSpell(spell) and GetSpellCount(spell) or -1
        end,
        value = function(value)
          return value
        end,
      }
      return function(button, prog)
        if button.Count then
          local k, v = next(prog)
          local count = countLang[k](v)
          button.Count:SetText(count < 0 and '' or count > 9999 and '*' or tostring(count))
        end
      end
    end)(),
    icon = function(button, icon)
      if button.icon then
        button.icon:SetTexture(icon)
      end
    end,
    name = function(button, name)
      (button.Name or button.Text):SetText(name)
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
          if button.icon then
            button.icon:SetVertexColor(getColor(foo))
          end
        end
      end
      local updateLang = {
        action = updateColor(IsActionInRange, IsUsableAction),
        item = updateColor(IsItemInRange, IsUsableItem),
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
        assert(lang[k], 'unknown function ' .. k)(button, v)
      end
    end
  end
end)()

local function makeActionButtons()
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
  local scripts = {
    OnEnter = function(self)
      if self.ttfn then
        GameTooltip_SetDefaultAnchor(GameTooltip, self)
        self.ttfn()
      end
    end,
    OnEvent = function(self)
      local binder = addonName .. 'ActionButton' .. self:GetID()
      local key = GetBindingKey('CLICK ' .. binder .. ':LeftButton')
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
      self:SetChecked(self.chfn())
    end,
  }
  local iconButtons = {}
  for row = 1, 4 do
    for col = 1, 12 do
      local button = CreateFrame(
          'CheckButton',
          addonName .. 'ActionIconButton' .. (#iconButtons + 1),
          UIParent,
          'ActionButtonTemplate, SecureActionButtonTemplate')
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
      table.insert(iconButtons, button)
    end
  end
  local textButtons = {}
  for row = 1, 8 do
    for col = 1, 6 do
      local idx = (row - 1) * 6 + col
      local button = CreateFrame(
          'Button',
          addonName .. 'ActionTextButton' .. idx,
          UIParent,
          'UIPanelButtonTemplate, SecureActionButtonTemplate')
      attachToTextGrid(button, row, col)
      table.insert(textButtons, button)
    end
  end
  return {
    icon = iconButtons,
    text = textButtons,
  }
end

local actionPage = 'invalid'
local actionButtonState = {}

local function setupHeader(actions, defaultPage, actionButtons, getActionButton)
  local prefix = addonName .. 'ActionButton'
  local header = CreateFrame('Frame', prefix .. 'Header', UIParent, 'SecureHandlerStateTemplate')
  header:Execute(([[defaultPage = %q]]):format(defaultPage))
  header:Execute([[
    actionPages = newtable()
    buttonPages = newtable()
    keybinders = newtable()
    updateActionButton = [=[
      local idx = ...
      local currentPage = owner:GetAttribute('fractionpage')
      local actionPage = actionPages[currentPage]
      local attr = actionPage.attrs[idx] or ''
      local type_, action, macrotext, index, filter
      if attr:sub(1, 8) == '#action:' then
        type_, action = 'action', tonumber(attr:sub(9))
      elseif attr:sub(1, 11) == '#petaction:' then
        type_, action = 'pet', tonumber(attr:sub(12))
      elseif attr:sub(1, 12) == '#cancelaura:' then
        type_, index, filter = 'cancelaura', tonumber(attr:sub(13, 14)), attr:sub(16)
      else
        type_, macrotext = 'macro', attr
      end
      local button = buttonPages[actionPage.buttonPage][idx]
      button:SetAttribute('type', type_)
      button:SetAttribute('action', action)
      button:SetAttribute('macrotext', macrotext)
      button:SetAttribute('index', index)
      button:SetAttribute('filter', filter)
      if attr ~= '' then
        owner:CallMethod('InsecureActionButtonRefresh', idx)
        button:Show()
      else
        button:Hide()
      end
    ]=]
    updateActionAttr = [=[
      local pageName, idx, attr = ...
      actionPages[pageName].attrs[idx] = attr
      if pageName == owner:GetAttribute('fractionpage') then
        owner:Run(updateActionButton, idx)
      end
    ]=]
    updateActionPage = [=[
      local page = ...
      local currentPage = owner:GetAttribute('fractionpage')
      if page ~= currentPage then
        owner:CallMethod('InsecureUpdateActionPage', page)
        local newButtonPage = actionPages[page].buttonPage
        if currentPage then
          local oldButtonPage = actionPages[currentPage].buttonPage
          if oldButtonPage ~= newButtonPage then
            for _, button in ipairs(buttonPages[oldButtonPage]) do
              button:Hide()
            end
          end
        end
        owner:SetAttribute('fractionpage', page)
        for i, keybinder in ipairs(keybinders) do
          local button = buttonPages[newButtonPage][i]
          local macrotext = button and ('/click ' .. button:GetName()) or ''
          keybinder:SetAttribute('macrotext', macrotext)
        end
        for buttonid, button in ipairs(buttonPages[newButtonPage]) do
          owner:Run(updateActionButton, buttonid)
        end
      end
    ]=]
    updatePageOnClick = [=[
      local buttonid = ...
      local currentPage = actionPages[owner:GetAttribute('fractionpage')]
      local attr = currentPage.attrs[buttonid] or ''
      local page = attr:sub(1, 6) == '#page:' and attr:sub(7) or currentPage.nextActionPage
      owner:Run(updateActionPage, page)
    ]=]
  ]])

  for name, page in pairs(actions) do
    header:Execute(([[
      local name, buttonPage, nextActionPage = %q, %q, %q
      local t = newtable()
      t.attrs = newtable()
      t.buttonPage = buttonPage
      t.nextActionPage = nextActionPage
      actionPages[name] = t
    ]]):format(name, page.buttonPage, page.nextActionPage))
  end

  for buttonPageName, buttons in pairs(actionButtons) do
    header:Execute(([[
      local buttonPageName = %q
      buttonPages[buttonPageName] = buttonPages[buttonPageName] or newtable()
    ]]):format(buttonPageName))
    for idx, button in ipairs(buttons) do
      button:Hide()
      button:SetID(idx)
      header:WrapScript(button, 'OnClick', 'return nil, true', [[
        owner:Run(updatePageOnClick, self:GetID())
      ]])
      header:SetFrameRef('tmp', button)
      header:Execute(([[
        tinsert(buttonPages[%q], self:GetFrameRef('tmp'))
      ]]):format(buttonPageName))
    end
  end

  local len = 0
  for _, buttons in pairs(actionButtons) do
    len = math.max(len, #buttons)
  end
  for i = 1, len do
    local button = CreateFrame('Button', prefix .. i, nil, 'SecureActionButtonTemplate')
    button:SetAttribute('type', 'macro')
    header:SetFrameRef('tmp', button)
    header:Execute([[tinsert(keybinders, self:GetFrameRef('tmp'))]])
  end

  RegisterAttributeDriver(header, 'state-petexists', '[@pet,exists] true; false')
  header:SetAttribute('_onstate-petexists', [=[
    -- If we just got a pet and it's not a hunter/warlock pet, switch to the pet page.
    -- If we just lost a pet and we're on the pet page, go back to the default page.
    local petExists = newstate == 'true'
    local creatureFamily, petName = PlayerPetSummary()
    if petExists and not creatureFamily and petName ~= 'Shadowfiend' then
      owner:Run(updateActionPage, 'pet')
    elseif not petExists and owner:GetAttribute('fractionpage') == 'pet' then
      owner:Run(updateActionPage, defaultPage)
    end
  ]=])

  header.InsecureActionButtonRefresh = function(_, idx)
    local reset = {
      alpha = 1.0,
      autocast = 'disallowed',
      checked = { value = false },
      color = 1.0,
      cooldown = { reset = true },
      count = { value = -1 },
      icon = 136235,  -- samwise
      name = '',
      tooltip = { reset = true },
    }
    updateButton(getActionButton(idx), Mixin(reset, actionButtonState[actionPage][idx]))
  end
  header.InsecureUpdateActionPage = function(_, newPage)
    actionPage = newPage
  end

  header:RegisterEvent('PLAYER_ENTERING_WORLD')
  header:SetScript('OnEvent', function(self)
    self:Execute([[self:Run(updateActionPage, defaultPage)]])
  end)

  for page in pairs(actions) do
    local name = page:gsub('^%l', string.upper)
    local switch = CreateFrame('Button', prefix .. name .. 'Switcher', header, 'SecureActionButtonTemplate')
    header:WrapScript(switch, 'OnClick', 'return nil, true', ([=[
      local page = %q
      owner:Run(updateActionPage, owner:GetAttribute('fractionpage') == page and defaultPage or page)
    ]=]):format(page))
  end

  local function updateAttr(pageName, idx, attr)
    header:Execute(([[self:Run(updateActionAttr, %q, %d, %q)]]):format(pageName, idx, attr))
  end

  return updateAttr
end

local function setupActions(actions, defaultPage, actionButtons)
  local function getActionButton(idx)
    local buttonPage = actions[actionPage].buttonPage
    return actionButtons[buttonPage][idx]
  end
  local updateAttr = setupHeader(actions, defaultPage, actionButtons, getActionButton)
  local maybeSetAttr, drainPendingAttrs = (function()
    local pendingAttrs = {}
    local function maybeSetAttr(pageName, idx, attr)
      if InCombatLockdown() then
        pendingAttrs[pageName] = pendingAttrs[pageName] or {}
        pendingAttrs[pageName][idx] = attr
      else
        updateAttr(pageName, idx, attr)
      end
    end
    local function drainPendingAttrs()
      for pageName, pageAttrs in pairs(pendingAttrs) do
        for idx, attr in pairs(pageAttrs) do
          updateAttr(pageName, idx, attr)
        end
        wipe(pageAttrs)
      end
    end
    return maybeSetAttr, drainPendingAttrs
  end)()
  local updateAction = (function()
    local uiLang = {
      hide = function()
        return {
          alpha = 0.0,
          tooltip = { reset = true },
        }
      end,
      item = function(item)
        return {
          alpha = 1.0,
          color = IsUsableItem(item) and 1.0 or 0.4,
          cooldown = { item = item },
          count = { item = item },
          icon = GetItemIcon(item),
          tooltip = { item = item },
          update = { item = item },
        }
      end,
      spell = function(spell)
        return {
          alpha = 1.0,
          checked = { spell = spell },
          cooldown = { spell = spell },
          count = { spell = spell },
          icon = GetSpellTexture(spell),
          tooltip = { spell = spell },
          update = { spell = spell },
        }
      end,
    }
    return function(pageName, idx, update)
      if update.attr then
        maybeSetAttr(pageName, idx, update.attr)
        update.attr = nil
      end
      if update.ui then
        local k, v = next(update.ui)
        update = Mixin({}, uiLang[k](v), update)
        update.ui = nil
      end
      Mixin(actionButtonState[pageName][idx], update)
      if pageName == actionPage then
        updateButton(getActionButton(idx), update)
      end
    end
  end)()
  local handlers = {}
  local function addHandler(ev, handler)
    handlers[ev] = handlers[ev] or {}
    table.insert(handlers[ev], handler)
  end
  for pageName, page in pairs(actions) do
    actionButtonState[pageName] = {}
    for idx, action in pairs(page.actions) do
      actionButtonState[pageName][idx] = {}
      local init, tyhandlers = makeAction(action)
      updateAction(pageName, idx, init)
      for ev, handler in pairs(tyhandlers or {}) do
        addHandler(ev, function(...)
          return updateAction(pageName, idx, handler(...))
        end)
      end
    end
  end
  local function updateHandler(name)
    return function()
      for idx, state in pairs(actionButtonState[actionPage]) do
        if state[name] then
          updateButton(getActionButton(idx), { [name] = state[name] })
        end
      end
    end
  end
  local genericHandlers = {
    BAG_UPDATE_DELAYED = updateHandler('count'),
    CURRENT_SPELL_CAST_CHANGED = updateHandler('checked'),
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
  local fractionPage, extraPages = (function()
    local classActions = G.ClassActionSpecs[select(3, UnitClass('player'))]
    local page, extra = {}, {}
    for i, v in pairs(classActions or {}) do
      if v.page then
        local pageName = 'fraction' .. i .. 'x'
        page[i] = Mixin({}, v, { page = pageName })
        local subpage = {}
        for j, x in pairs(v.page) do
          subpage[j] = x
        end
        extra[pageName] = subpage
      elseif v.oneof then
        local spells, subpage = {}, {}
        for j, sp in pairs(v.oneof) do
          table.insert(spells, sp)
          subpage[j] = { spell = sp }
        end
        local pageName = 'fraction' .. i .. 'x'
        page[i] = Mixin({}, v, { oneof = spells, oneofpage = pageName })
        extra[pageName] = subpage
      elseif v.stopcasting and not (v.spell or v.spells) then
        page[i] = {
          actionText = 'Stop',
          macro = '/stopcasting',
          texture = 135768,
          tooltip = 'Stop Casting',
        }
      elseif v.racial then
        page[i] = {
          spell = ({
            ['Blood Elf'] = 'Arcane Torrent',
            Draenei = 'Gift of the Naaru',
            Dwarf = 'Stoneform',
            Gnome = 'Escape Artist',
            Human = 'Perception',
            ['Night Elf'] = 'Shadowmeld',
            Orc = 'Blood Fury',
            Tauren = 'War Stomp',
            Troll = 'Berserking',
            Undead = 'Will of the Forsaken',
          })[UnitRace('player')]
        }
      elseif v.racial2 then
        local spell = ({
          ['Blood Elf'] = 'Mana Tap',
          Undead = 'Cannibalize',
        })[UnitRace('player')]
        page[i] = spell and { spell = spell } or nil
      else
        page[i] = v
      end
    end
    return page, extra
  end)()
  local actionPages = Mixin(extraPages, {
    action1 = (function()
      local page = {}
      for i = 1, 48 do
        table.insert(page, { action = i })
      end
      return page
    end)(),
    action2 = (function()
      local page = {}
      for i = 49, 72 do
        table.insert(page, { action = i })
      end
      return page
    end)(),
    aura = (function()
      local page = {}
      for i = 1, 40 do
        table.insert(page, {
          aura = {
            filter = 'CANCELABLE',
            index = i,
          },
        })
      end
      return page
    end)(),
    emote = (function()
      local emotes = {
        'lol',
        'thank',
        'cheer',
        'wave',
        'hello',
        'train',
        'rude',
        'congratulate',
        'moo',
        'oom',
        'attacktarget',
        'charge',
        'mourn',
        'tickle',
        'roar',
        'rofl',
        'hug',
        'kiss',
        'love',
        'hungry',
        'thirsty',
        'ready',
        'sleep',
        'sigh',
        'nod',
        'no',
        'threaten',
        'silly',
        'question',
        'welcome',
        'hail',
      }
      local page = {}
      for i, emote in ipairs(emotes) do
        table.insert(page, {
          emote = emote,
          index = i,
        })
      end
      return page
    end)(),
    fraction = fractionPage,
    noncombat = (function()
      local page = {}
      for i = 1, 10 do
        table.insert(page, { noncombat = i })
      end
      return page
    end)(),
    pet = (function()
      local page = {}
      for i = 1, NUM_PET_ACTION_SLOTS do
        table.insert(page, { petaction = i })
      end
      table.insert(page, {
        macro = '/cancelaura Mind Control',
        texture = 136206,
        tooltip = 'Cancel Mind Control',
      })
      table.insert(page, {
        macro = '/petdismiss',
        texture = 'interface/icons/spell_nature_spiritwolf',
        tooltip = 'Dismiss Pet',
      })
      return page
    end)(),
    profession = (function()
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
        'Jewelcrafting',
        'Prospecting',
      }
      local page = {}
      for _, spell in ipairs(professions) do
        table.insert(page, {
          dismount = false,
          spell = spell,
          stand = false,
        })
      end
      return page
    end)(),
  })
  local defaultPage = next(fractionPage) and 'fraction' or 'action1'
  local actions = (function()
    local t = {}
    for k, v in pairs(actionPages) do
      t[k] = {
        actions = v,
        buttonPage = k == 'emote' and 'text' or 'icon',
        nextActionPage = k == 'pet' and k or defaultPage,
      }
    end
    return t
  end)()
  return actions, defaultPage
end

G.Eventer({
  PLAYER_LOGIN = function()
    G.ReparentFrame(MainMenuBar)
    local actions, defaultPage = makeActions()
    local actionButtons = makeActionButtons()
    setupActions(actions, defaultPage, actionButtons)
  end,
})

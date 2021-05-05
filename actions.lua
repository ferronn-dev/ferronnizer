local addonName, G = ...

local prefix = addonName .. 'ActionButton'
local header = CreateFrame('Frame', prefix .. 'Header', UIParent, 'SecureHandlerStateTemplate')

local function updateCooldown(button, cdfn, action)
  local start, duration, enable, modRate = cdfn(action)
  CooldownFrame_Set(button.cooldown, start, duration, enable, false, modRate)
end

local customTypes = (function()
  local libCount = LibStub('LibClassicSpellActionCount-1.0')
  local function updateCount(button, item)
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
    local function updateItem(button)
      item = computeItem()
      updateCount(button, item)
      updateCooldown(button, getCooldown)
      button.icon:SetTexture(GetItemIcon(item))
      button.icon:Show()
    end
    local function updateDB(button, db)
      currentDB = db
      button:SetAttribute('macrotext', macroText(db))
      updateItem(button)
    end
    return {
      getCooldown = getCooldown,
      handlers = {
        BAG_UPDATE_DELAYED = function(button)
          updateItem(button)
        end,
        PLAYER_REGEN_DISABLED = function(button)
          updateDB(button, potionDB)
        end,
        PLAYER_REGEN_ENABLED = function(button)
          updateDB(button, mealDB)
        end,
      },
      init = function(button)
        updateDB(button, mealDB)
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
        BAG_UPDATE_DELAYED = function(button, action)
          if action.reagent then
            updateCount(button, action.reagent)
          end
        end,
      },
      init = function(button)
        button.icon:SetTexture(135938)
        button:SetAttribute('macrotext', '/click ' .. addonName .. 'BuffButton')
      end,
      setTooltip = function()
        GameTooltip:SetText('Buff')
      end,
    },
    drink = consume(G.DrinkDB, G.ManaPotionDB),
    eat = consume(G.FoodDB, G.HealthPotionDB),
    empty = {
      getCooldown = function() end,
      handlers = {},
      init = function(button)
        button:Hide()
      end,
      setTooltip = function() end,
    },
    invslot = (function()
      local function getCooldown(action)
        return GetInventoryItemCooldown('player', action.invslot)
      end
      local function update(button, action)
        local item = GetInventoryItemID('player', action.invslot)
        button.icon:SetTexture(item and GetItemIcon(item) or 136528)
        if item and GetItemSpell(item) then
          button:Enable(true)
          button.icon:SetVertexColor(1.0, 1.0, 1.0)
        else
          button:Disable()
          button.icon:SetVertexColor(0.4, 0.4, 0.4)
        end
        updateCooldown(button, getCooldown, action)
      end
      return {
        getCooldown = getCooldown,
        handlers = {
          PLAYER_EQUIPMENT_CHANGED = update,
        },
        init = function(button, action)
          button:SetAttribute('macrotext', '/use ' .. action.invslot)
          update(button, action)
        end,
        setTooltip = function(action)
          local item = GetInventoryItemID('player', action.invslot)
          local spell = item and select(2, GetItemSpell(item))
          if spell and IsShiftKeyDown() then
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
      init = function(button, action)
        if action.actionText then
          button.Name:SetText(action.actionText)
        end
        button.icon:SetTexture(action.texture)
        button:SetAttribute('macrotext', action.macro)
      end,
      setTooltip = function(action)
        GameTooltip:SetText(action.tooltip)
      end,
    },
    mount = (function()
      local tooltipFn
      local function updateMacro(button, text)
        if not InCombatLockdown() then
          button:SetEnabled(text ~= '')
          button:SetAttribute('macrotext', '/stand\n/cancelform\n' .. text)
        end
      end
      local function update(button)
        for _, spellx in ipairs(G.MountSpellDB) do
          local spell = spellx[1]
          if IsSpellKnown(spell) then
            updateMacro(button, '/cast ' .. GetSpellInfo(spell))
            button.icon:SetVertexColor(1.0, 1.0, 1.0)
            button.icon:SetTexture(GetSpellTexture(spell))
            tooltipFn = function()
              GameTooltip:SetSpellByID(spell)
            end
            return
          end
        end
        for _, itemx in ipairs(G.MountItemDB) do
          local item = itemx[1]
          if GetItemCount(item) > 0 then
            updateMacro(button, '/use item:' .. item)
            button.icon:SetVertexColor(1.0, 1.0, 1.0)
            button.icon:SetTexture(GetItemIcon(item))
            tooltipFn = function()
              GameTooltip:SetHyperlink('item:' .. item)
            end
            return
          end
        end
        updateMacro(button, '')
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
          PLAYER_REGEN_DISABLED = function(button)
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
    spell = (function()
      return {
        getCooldown = function(action)
          return GetSpellCooldown(action.spell)
        end,
        handlers = {
          BAG_UPDATE_DELAYED = function(button, action)
            local count = libCount:GetSpellReagentCount(action.spell)
            button.Count:SetText(count == nil and '' or count > 9999 and '*' or count)
          end,
        },
        init = function(button, action)
          button:SetAttribute('macrotext', (
             '/dismount\n/stand\n'..
             (action.stopcasting and '/stopcasting\n' or '')..
             '/cast'..(action.mouseover and ' [@mouseover,help,nodead][] ' or ' ')..
             action.spell))
          button.icon:SetTexture(GetSpellTexture(action.spell))
          if action.actionText then
            button.Name:SetText(action.actionText)
          end
        end,
        setTooltip = function(action)
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
    end)(),
    stopcasting = {
      getCooldown = function() end,
      handlers = {},
      init = function(button)
        button.Name:SetText('Stop')
        button.icon:SetTexture(135768)
        button:SetAttribute('macrotext', '/stopcasting')
      end,
      setTooltip = function()
        GameTooltip:SetText('Stop Casting')
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

local function makeCustomActionButton(i, action)
  local button = CreateFrame(
      'CheckButton', prefix .. i, header, 'ActionButtonTemplate, SecureActionButtonTemplate')
  local ty = getType(action)
  button:SetAttribute('type', 'macro')
  button:SetMotionScriptsWhileDisabled(true)
  button.HotKey:SetFont(button.HotKey:GetFont(), 13, 'OUTLINE')
  button.HotKey:SetVertexColor(0.75, 0.75, 0.75)
  button.HotKey:SetPoint('TOPLEFT', button, 'TOPLEFT', -2, -4)
  button.Count:SetFont(button.Count:GetFont(), 16, 'OUTLINE')
  button:SetNormalTexture('Interface\\Buttons\\UI-Quickslot2')
  button.NormalTexture:SetTexCoord(0, 0, 0, 0)
  button.cooldown:SetSwipeColor(0, 0, 0)
  ty.init(button, action)
  button:SetScript('OnEnter', function()
    GameTooltip_SetDefaultAnchor(GameTooltip, button)
    ty.setTooltip(action)
  end)
  button:SetScript('OnLeave', function()
    GameTooltip:Hide()
  end)
  button:SetScript('PostClick', function()
    button:SetChecked(false)
  end)
  button:SetScript('OnEvent', (function()
    local handlers = ty.handlers
    button:UnregisterAllEvents()
    for ev in pairs(handlers) do
      button:RegisterEvent(ev)
    end
    return function(self, ev, ...)
      handlers[ev](self, action, ...)
    end
  end)())
  return button, ty
end

local function makeCustomActionButtons(actions)
  local buttons = {}
  local customActionButtons = {}
  for i = 1, 48 do
    local button, ty = makeCustomActionButton(i, actions[i] or { empty = true })
    table.insert(buttons, button)
    customActionButtons[button] = ty
  end
  -- Handle generic events separately from individual button OnEvent handlers.
  local keyBound = LibStub('LibKeyBound-1.0')
  G.Eventer({
    SPELL_UPDATE_COOLDOWN = function()
      for i, button in ipairs(buttons) do
        updateCooldown(button, customActionButtons[button].getCooldown, actions[i])
      end
    end,
    UPDATE_BINDINGS = function()
      for button in pairs(customActionButtons) do
        local key = GetBindingKey('CLICK ' .. button:GetName() .. ':LeftButton')
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
  local LAB10 = LibStub('LibActionButton-1.0')
  -- LAB bug
  G.Eventer({
    BAG_UPDATE_DELAYED = function()
      LAB10.eventFrame:GetScript('OnEvent')(LAB10.eventFrame, 'SPELL_UPDATE_CHARGES')
    end,
  })
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

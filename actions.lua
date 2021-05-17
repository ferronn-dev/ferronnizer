local addonName, G = ...

local prefix = addonName .. 'ActionButton'
local header = CreateFrame('Frame', prefix .. 'Header', UIParent, 'SecureHandlerStateTemplate')

local customTypes = (function()
  local libCount = LibStub('LibClassicSpellActionCount-1.0')
  local function formatCount(item)
    local count = GetItemCount(item)
    return count > 9999 and '*' or count
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
    local function getCooldown()
      return GetItemCooldown(item)
    end
    local function updateItem(level)
      item = computeItem(level)
      return {
        cooldown = getCooldown,
        count = formatCount(item),
        icon = GetItemIcon(item),
      }
    end
    local function updateDB(db)
      currentDB = db
      return Mixin(updateItem(), { macro = macroText(db) })
    end
    return {
      getCooldown = getCooldown,
      handlers = {
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
      },
      init = function()
        return updateDB(mealDB)
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
        BAG_UPDATE_DELAYED = function(action)
          return {
            count = action.reagent and formatCount(action.reagent)
          }
        end,
      },
      init = function()
        return {
          icon = 135938,
          macro = '/click ' .. addonName .. 'BuffButton',
        }
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
      init = function()
        return { shown = false }
      end,
      setTooltip = function() end,
    },
    invslot = (function()
      local function getCooldown(action)
        return GetInventoryItemCooldown('player', action.invslot)
      end
      local function update(action)
        local item = GetInventoryItemID('player', action.invslot)
        local usable = item and GetItemSpell(item)
        return {
          color = usable and 1.0 or 0.4,
          cooldown = function() getCooldown(action) end,
          enabled = usable,
          icon = item and GetItemIcon(item) or 136528,
        }
      end
      return {
        getCooldown = getCooldown,
        handlers = {
          PLAYER_EQUIPMENT_CHANGED = update,
        },
        init = function(action)
          return Mixin(update(action), { macro = '/use ' .. action.invslot })
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
      init = function(action)
        return {
          name = action.actionText,
          icon = action.texture,
          macro = action.macro,
        }
      end,
      setTooltip = function(action)
        GameTooltip:SetText(action.tooltip)
      end,
    },
    mount = (function()
      local tooltipFn
      local function update()
        for _, spellx in ipairs(G.MountSpellDB) do
          local spell = spellx[1]
          if IsSpellKnown(spell) then
            tooltipFn = function()
              GameTooltip:SetSpellByID(spell)
            end
            return {
              color = 1.0,
              icon = GetSpellTexture(spell),
              macro = '/cast ' .. GetSpellInfo(spell),
            }
          end
        end
        for _, itemx in ipairs(G.MountItemDB) do
          local item = itemx[1]
          if GetItemCount(item) > 0 then
            tooltipFn = function()
              GameTooltip:SetHyperlink('item:' .. item)
            end
            return {
              color = 1.0,
              icon = GetItemIcon(item),
              macro = '/use item:' .. item,
            }
          end
        end
        tooltipFn = function()
          GameTooltip:SetText('No mount... yet.')
        end
        return {
          color = 0.4,
          icon = 132261,
          macro = '',
        }
      end
      return {
        getCooldown = getGcdCooldown,
        handlers = {
          BAG_UPDATE_DELAYED = update,
          PLAYER_REGEN_DISABLED = function()
            return { macro = '/dismount' }
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
      local function fullName(action)
        return action.spell .. (action.rank and ('(Rank ' .. action.rank .. ')') or '')
      end
      return {
        getCooldown = function(action)
          return GetSpellCooldown(fullName(action))
        end,
        handlers = {
          BAG_UPDATE_DELAYED = function(action)
            local count = libCount:GetSpellReagentCount(fullName(action))
            return { count = count == nil and '' or count > 9999 and '*' or count }
          end,
        },
        init = function(action)
          return {
            -- Use the spell base name for GetSpellTexture; more likely to work on login.
            icon = GetSpellTexture(action.spell),
            macro = (
              '/dismount\n/stand\n'..
              (action.stopcasting and '/stopcasting\n' or '')..
              '/cast'..(action.mouseover and ' [@mouseover,help,nodead][] ' or ' ')..
              fullName(action)),
            name = action.actionText,
          }
        end,
        setTooltip = function(action)
          local id = select(7, GetSpellInfo(fullName(action)))
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
      init = function()
        return {
          icon = 135768,
          macro = '/stopcasting',
          name = 'Stop',
        }
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

local buttonLang = {
  color = function(button, color)
    button.icon:SetVertexColor(color, color, color)
  end,
  cooldown = function(button, fn)
    local start, duration, enable, modRate = fn()
    CooldownFrame_Set(button.cooldown, start, duration, enable, false, modRate)
  end,
  count = function(button, count)
    button.Count:SetText(count)
  end,
  enabled = function(button, enabled)
    if not InCombatLockdown() then
      button:SetEnabled(enabled)
    end
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
  shown = function(button, shown)
    if not InCombatLockdown() then
      button:SetShown(shown)
    end
  end,
}

local function updateButton(button, arg)
  for k, v in pairs(arg) do
    buttonLang[k](button, v)
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
  updateButton(button, ty.init(action))
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
      updateButton(self, handlers[ev](action, ...))
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
      local update = buttonLang.cooldown
      for i, button in ipairs(buttons) do
        local cdfn = customActionButtons[button].getCooldown
        update(button, function() cdfn(actions[i]) end)
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

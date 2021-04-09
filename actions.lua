local addonName, G = ...

local libCount = LibStub('LibClassicSpellActionCount-1.0')

local actions = (function()
  local characters = {
    ['Kewhand-Westfall'] = {
      [1] = {
        spell = 'Judgement',
      },
      [2] = {
        mouseover = true,
        spell = 'Holy Light(Rank 8)',
      },
      [3] = {
        mouseover = true,
        spell = 'Flash of Light(Rank 6)',
      },
      [4] = {
        mouseover = true,
        spell = 'Holy Shock(Rank 3)',
      },
      [5] = {
        spell = 'Hammer of Justice',
      },
      [6] = {
        spell = 'Consecration',
      },
      [7] = {
        mouseover = true,
        spell = 'Cleanse',
      },
      [8] = {
        spell = 'Divine Favor',
      },
      [9] = {
        spell = 'Exorcism',
      },
      [10] = {
        spell = 'Hammer of Wrath',
      },
      [11] = {
        spell = 'Holy Wrath',
      },
      [12] = {
        spell = 'Turn Undead',
      },
      [13] = {
        spell = 'Devotion Aura',
      },
      [14] = {
        spell = 'Retribution Aura',
      },
      [15] = {
        spell = 'Concentration Aura',
      },
      [16] = {
        spell = 'Frost Resistance Aura',
      },
      [17] = {
        spell = 'Fire Resistance Aura',
      },
      [18] = {
        spell = 'Shadow Resistance Aura',
      },
      [19] = {
        spell = 'Blessing of Might',
      },
      [20] = {
        spell = 'Righteous Fury',
      },
      [21] = {
        spell = 'Redemption',
      },
      [22] = {
        spell = 'Greater Blessing of Light',
      },
      [23] = {
        spell = 'Greater Blessing of Salvation',
      },
      [24] = {
        spell = 'Greater Blessing of Might',
      },
      [39] = {
        spell = 'Smelting',
      },
      [45] = {
        item = 6948,
      },
    },
    ['Shydove-Westfall'] = {
      [1] = {
        actionText = 'GH4',
        mouseover = true,
        spell = 'Greater Heal(Rank 4)',
      },
      [2] = {
        actionText = 'GH2',
        mouseover = true,
        spell = 'Greater Heal(Rank 2)',
      },
      [3] = {
        actionText = 'H4',
        mouseover = true,
        spell = 'Heal(Rank 4)',
      },
      [4] = {
        actionText = 'Stop',
        macro = '/stopcasting',
        texture = 135768,
        tooltip = 'Stop Casting',
      },
      [5] = {
        mouseover = true,
        spell = 'Renew',
      },
      [6] = {
        spell = 'Holy Nova',
      },
      [7] = {
        mouseover = true,
        spell = 'Power Word: Shield',
      },
      [8] = {
        spell = '!Shoot',
      },
      [9] = {
        spell = 'Smite',
      },
      [10] = {
        spell = 'Shadow Word: Pain',
      },
      [11] = {
        spell = 'Mind Blast',
      },
      [12] = {
        spell = 'Psychic Scream',
      },
      [13] = {
        actionText = 'FH7',
        mouseover = true,
        spell = 'Flash Heal(Rank 7)',
      },
      [14] = {
        actionText = 'FH3',
        mouseover = true,
        spell = 'Flash Heal(Rank 3)',
      },
      [15] = {
        actionText = 'FH2',
        mouseover = true,
        spell = 'Flash Heal(Rank 2)',
      },
      [16] = {
        actionText = 'Stop',
        macro = '/stopcasting',
        texture = 135768,
        tooltip = 'Stop Casting',
      },
      [17] = {
        spell = 'Inner Focus',
      },
      [18] = {
        spell = 'Prayer of Healing',
      },
      [19] = {
        item = 19950,
      },
      [20] = {
        item = 19990,
      },
      [21] = {
        mouseover = true,
        spell = 'Power Infusion',
      },
      [22] = {
        mouseover = true,
        spell = 'Shadow Protection',
      },
      [23] = {
        mouseover = true,
        spell = 'Power Word: Fortitude',
      },
      [24] = {
        mouseover = true,
        spell = 'Divine Spirit',
      },
      [25] = {
        mouseover = true,
        spell = 'Dispel Magic',
      },
      [26] = {
        mouseover = true,
        spell = 'Abolish Disease',
      },
      [27] = {
        spell = 'Fade',
      },
      [28] = {
        spell = 'Desperate Prayer',
      },
      [29] = {
        spell = 'Inner Fire',
      },
      [30] = {
        spell = 'Shackle Undead',
      },
      [31] = {
        spell = 'Perception',
      },
      [32] = {
        spell = 'Holy Fire',
      },
      [33] = {
        spell = 'Resurrection',
      },
      [34] = {
        spell = 'Prayer of Shadow Protection',
      },
      [35] = {
        spell = 'Prayer of Fortitude',
      },
      [36] = {
        spell = 'Prayer of Spirit',
      },
      [37] = {
        spell = 'Fishing',
      },
      [38] = {
        spell = 'Tailoring',
      },
      [39] = {
        spell = 'Cooking',
      },
      [40] = {
        spell = 'First Aid',
      },
      [41] = {
        spell = 'Mind Control',
      },
      [42] = {
        spell = 'Find Herbs',
      },
      [43] = {
        item = 18778,
      },
      [44] = {
        item = 13446,
      },
      [45] = {
        item = 13444,
      },
      [46] = {
        item = 8079,
      },
      [47] = {
        spell = 'Mana Burn',
      },
      [48] = {
        spell = 'Mind Soothe',
      },
    },
  }
  local charName = UnitName('player')..'-'..GetRealmName()
  return characters[charName] or {}
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
    GetCooldown = function(item)
      return GetItemCooldown(item)
    end,
    GetCount = function(item)
      return GetItemCount(item)
    end,
    GetTexture = function(item)
      return _G.GetItemIcon(item)
    end,
    IsConsumableOrStackable = function(item)
      -- LAB bug
      local stack = select(8, GetItemInfo(item))
      return _G.IsConsumableItem(item) or (stack and stack > 1)
    end,
    IsCurrentlyActive = function(item)
      return _G.IsCurrentItem(item)
    end,
    IsUnitInRange = function(item, unit)
      return _G.IsItemInRange(item, unit)
    end,
    IsUsable = function(item)
      return _G.IsUsableItem(item)
    end,
    SetTooltip = function(item)
      return GameTooltip:SetHyperlink('item:'..item)
    end,
  },
  macro = {
    IsUsable = function()
      return true
    end,
  },
  spell = {
    GetCooldown = function(spell)
      return GetSpellCooldown(spell)
    end,
    GetCount = function(spell)
      -- LAB bug
      return libCount:GetSpellReagentCount(spell)
    end,
    GetTexture = function(spell)
      return GetSpellTexture(spell)
    end,
    IsConsumableOrStackable = function(spell)
      return _G.IsConsumableSpell(spell)
    end,
    IsCurrentlyActive = function(spell)
      return _G.IsCurrentSpell(spell)
    end,
    IsUnitInRange = function(spell, unit)
      local id = select(7, GetSpellInfo(spell))
      local slot = _G.FindSpellBookSlotBySpellID(id)
      return _G.IsSpellInRange(slot, 'spell', unit)
    end,
    IsUsable = function(spell)
      return IsUsableSpell(spell)
    end,
    SetTooltip = function(spell)
      local id = select(7, GetSpellInfo(spell))
      GameTooltip:SetSpellByID(id)
      local subtext = GetSpellSubtext(id)
      if subtext then
        _G.GameTooltipTextRight1:SetText(subtext)
        _G.GameTooltipTextRight1:Show()
        GameTooltip:Show()
      end
    end,
  },
}

local buttonMixin = {}
for k, v in pairs(types.default) do
  buttonMixin[k] = function(self, ...)
    local action = actions[self._state_action] or {}
    if action.spell and types.spell[k] then
      return types.spell[k](action.spell, ...)
    elseif action.item and types.item[k] then
      return types.item[k](action.item, ...)
    elseif action.macro and types.macro[k] then
      return types.macro[k](action.macro, ...)
    else
      return v(action)
    end
  end
end

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
  for i = 1, 49 do
    local button = LAB10:CreateButton(i, prefix .. i, header)
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
    for i, button in ipairs(buttons) do
      local action = actions[i]
      if not action then
        button:SetState(0, 'action', i)
      else
        Mixin(button, buttonMixin)
        button:SetState(0, nil, i)
        button:SetAttribute('type', 'macro')
        button:SetAttribute('macrotext', (function()
          if action.item then
            return '/use item:'..action.item
          elseif action.spell then
            return (
               '/dismount\n/stand\n/cast'..
                (action.mouseover and ' [@mouseover,help,nodead][] ' or ' ')..
                action.spell)
          else
            return action.macro
          end
        end)())
      end
    end
  end,
})

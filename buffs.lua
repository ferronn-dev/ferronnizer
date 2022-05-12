local _, G = ...

local buffSlotSpecification = {
  {
    buffs = {
      {
        spell = 'Arcane Intellect',
        group = 'Arcane Brilliance',
      },
    },
  },
  {
    buffs = { { spell = 'Dampen Magic' } },
    solo = true,
  },
  {
    buffs = {
      { spell = 'Demon Armor' },
      { spell = 'Demon Skin' },
    },
    self = true,
  },
  {
    buffs = {
      {
        spell = 'Divine Spirit',
        group = 'Prayer of Spirit',
        classes = {
          'Paladin',
          'Mage',
          'Warlock',
          'Priest',
          'Hunter',
          'Druid',
          'Shaman',
        },
      },
    },
  },
  {
    buffs = { { spell = 'Ice Barrier' } },
    self = true,
  },
  {
    buffs = { { spell = 'Inner Fire' } },
    self = true,
  },
  {
    buffs = {
      { spell = 'Mage Armor' },
      { spell = 'Ice Armor' },
      { spell = 'Frost Armor' },
    },
    self = true,
  },
  {
    buffs = {
      {
        spell = 'Mark of the Wild',
        group = 'Gift of the Wild',
      },
    },
  },
  {
    buffs = {
      {
        spell = 'Power Word: Fortitude',
        group = 'Prayer of Fortitude',
      },
    },
  },
  {
    buffs = {
      {
        spell = 'Shadow Protection',
        group = 'Prayer of Shadow Protection',
      },
    },
  },
  {
    buffs = { { spell = 'Thorns' } },
  },
}

local thebuffdb = (function()
  local function rankInfo(rank)
    local id, level, reagent = unpack(rank)
    return { id = id, level = level, reagent = reagent }
  end
  local thebuffdb = {}
  for _, slotSpec in ipairs(buffSlotSpecification) do
    table.insert(thebuffdb, {
      buffs = (function()
        local buffs = {}
        for _, buffSpec in ipairs(slotSpec.buffs) do
          table.insert(buffs, {
            ranks = (function()
              local spellData = G.SpellDB[buffSpec.spell]
              local groupData = buffSpec.group and G.SpellDB[buffSpec.group] or {}
              assert(#spellData >= #groupData)
              local ranks = {}
              for i = 1, #spellData do
                table.insert(ranks, {
                  spell = rankInfo(spellData[i]),
                  group = groupData[i] and rankInfo(groupData[i]) or nil,
                })
              end
              return ranks
            end)(),
            classes = buffSpec.classes and (function()
              local t = {}
              for _, class in ipairs(buffSpec.classes) do
                t[class] = true
              end
              return t
            end)(),
          })
        end
        return buffs
      end)(),
      self = slotSpec.self,
      solo = slotSpec.solo,
    })
  end
  return thebuffdb
end)()

local function GetUnitBuffs(unit)
  local result = {}
  local i = 1
  local spellid = select(10, UnitBuff(unit, i))
  while spellid do
    result[spellid] = true
    i = i + 1
    spellid = select(10, UnitBuff(unit, i))
  end
  return result
end

local trackingdb = {
  { spell = 2580, texture = 136025 }, -- Find Minerals
  { spell = 2383, texture = 133939 }, -- Find Herbs
  { spell = 2481, texture = 135725 }, -- Find Treasure
}

local function consumeList(db)
  local spells = {}
  for _, e in ipairs(db) do
    local item, _, spell = unpack(e)
    if spell then
      table.insert(spells, { spell = spell, item = item })
    end
  end
  return spells
end

local conjuredb = {
  { count = 20, spells = consumeList(G.DrinkDB) },
  { count = 10, spells = consumeList(G.FoodDB) },
  { count = 1, spells = consumeList(G.ManaPotionDB) },
  { count = 1, spells = consumeList(G.HealthPotionDB) },
}

local function canCast(spell, unit)
  local slot = FindSpellBookSlotBySpellID(spell.id)
  return IsSpellKnown(spell.id)
    and spell.level - 10 <= UnitLevel(unit)
    and (not spell.reagent or GetItemCount(spell.reagent) > 0)
    and (not SpellHasRange(slot, 'spell') or IsSpellInRange(slot, 'spell', unit) == 1)
end

local function GetBuffToCast(unit)
  local buffs = GetUnitBuffs(unit)
  for _, slot in ipairs(thebuffdb) do
    local id = (function()
      if unit ~= 'player' and (slot.self or slot.solo) then
        return nil
      end
      if slot.solo and IsInGroup() then
        return nil
      end
      for _, buff in ipairs(slot.buffs) do
        local id, skip = (function()
          if buff.classes and not buff.classes[UnitClass(unit)] then
            return nil
          end
          for _, rank in ipairs(buff.ranks) do
            local spell = rank.spell
            local group = rank.group
            if buffs[spell.id] or group and buffs[group.id] then
              return nil, true
            end
            if group and (UnitInParty(unit) or UnitInRaid(unit)) and canCast(group, unit) then
              return group.id
            elseif canCast(spell, unit) then
              return spell.id
            end
          end
        end)()
        if skip then
          return nil
        elseif id then
          return id
        end
      end
    end)()
    if id then
      return id
    end
  end
end

local unitsToBuff = (function()
  local u = { 'target', 'player' }
  for i = 1, 4 do
    table.insert(u, 'party' .. i)
  end
  for i = 1, 40 do
    table.insert(u, 'raid' .. i)
  end
  return u
end)()

local function IsTracking(texture)
  if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
    return GetTrackingTexture() == texture
  else
    for i = 1, GetNumTrackingTypes() do
      local _, tex, active = GetTrackingInfo(i)
      if tex == texture then
        return active
      end
    end
    return false
  end
end

local function GetSpellToCast()
  for _, unit in ipairs(unitsToBuff) do
    if UnitExists(unit) then
      local spell = GetBuffToCast(unit)
      if spell then
        return spell, unit
      end
    end
  end
  for _, c in ipairs(conjuredb) do
    for _, s in ipairs(c.spells) do
      if IsSpellKnown(s.spell) then
        if GetItemCount(s.item) < c.count then
          return s.spell, 'player'
        end
        break
      end
    end
  end
  for _, track in ipairs(trackingdb) do
    if IsSpellKnown(track.spell) and not IsTracking(track.texture) then
      return track.spell, 'player'
    end
  end
end

G.PreClickButton('BuffButton', '', function()
  local spell, unit = GetSpellToCast()
  if spell and GetSpellCooldown(spell) == 0 and not select(2, IsUsableSpell(spell)) then
    local spellName, _, _, castTime = GetSpellInfo(spell)
    if castTime == 0 or GetUnitSpeed('player') == 0 then
      local subtext = GetSpellSubtext(spell)
      if subtext then
        spellName = spellName .. '(' .. subtext .. ')'
      end
      if not UnitIsUnit('player', unit) then
        print('Casting ' .. spellName .. ' on ' .. UnitName(unit) .. '.')
      end
      return '/stand\n/cancelform\n/cast [@' .. unit .. ']' .. spellName
    end
  end
end)

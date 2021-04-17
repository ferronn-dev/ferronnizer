local _, G = ...

G.TheTankUnit = ''
G.Salvation = false

local buffSlotSpecification = {
  {
    buffs = {
      {
        spell = 'Arcane Intellect',
        group = 'Arcane Brilliance',
      },
    },
  },{
    buffs = {
      {
        spell = 'Blessing of Salvation',
        group = 'Greater Blessing of Salvation',
        flag = 'Salvation',
        tank = false,
        party = true,
      },{
        spell = 'Blessing of Wisdom',
        group = 'Greater Blessing of Wisdom',
        classes = {'Paladin', 'Mage', 'Warlock', 'Priest', 'Hunter'},
      },{
        spell = 'Blessing of Might',
        group = 'Greater Blessing of Might',
        classes = {'Warrior', 'Rogue', 'Druid'},
      },{
        spell = 'Blessing of Kings',
        group = 'Greater Blessing of Kings',
        classes = {},  -- disabled
      },{
        spell = 'Blessing of Light',
        group = 'Greater Blessing of Light',
        classes = {},  -- disabled
      },
    },
  },{
    buffs = {
      { spell = 'Demon Armor' },
      { spell = 'Demon Skin' },
    },
    self = true,
  },{
    buffs = {
      {
        spell = 'Divine Spirit',
        group = 'Prayer of Spirit',
      },
    },
  },{
    buffs = { { spell = 'Ice Barrier' } },
    self = true,
  },{
    buffs = { { spell = 'Inner Fire' } },
    self = true,
  },{
    buffs = {
      { spell = 'Mage Armor' },
      { spell = 'Ice Armor' },
      { spell = 'Frost Armor' },
    },
    self = true,
  },{
    buffs = {
      {
        spell = 'Mark of the Wild',
        group = 'Gift of the Wild',
      },
    },
  },{
    buffs = {
      {
        spell = 'Power Word: Fortitude',
        group = 'Prayer of Fortitude',
      },
    },
  },{
    buffs = {
      { spell = 'Retribution Aura' },
      { spell = 'Devotion Aura' },
    },
    self = true,
  },{
    buffs = {
      {
        spell = 'Righteous Fury',
        tank = true,
      },
    },
    self = true,
  },{
    buffs = {
      {
        spell = 'Shadow Protection',
        group = 'Prayer of Shadow Protection',
      },
    },
  },{
    buffs = {
      {
        spell = 'Thorns',
        tank = true,
      },
    },
  },
}

local function rankInfo(rank)
  local id, level, reagent = unpack(rank)
  return { id = id, level = level, reagent = reagent }
end

local thebuffdb = {}
for _, slotSpec in ipairs(buffSlotSpecification) do
  local buffs = {}
  for _, buffSpec in ipairs(slotSpec.buffs) do
    local spellData = G.BuffDB[buffSpec.spell]
    local groupData = buffSpec.group and G.BuffDB[buffSpec.group] or {}
    assert(#spellData >= #groupData)
    local ranks = {}
    for i = 1, #spellData do
      table.insert(ranks, {
        spell = rankInfo(spellData[i]),
        group = groupData[i] and rankInfo(groupData[i]) or nil
      })
    end
    table.insert(buffs, {
      ranks = ranks,
      classes = buffSpec.classes,
      tank = buffSpec.tank,
      flag = buffSpec.flag,
    })
  end
  table.insert(thebuffdb, {
    buffs = buffs,
    self = slotSpec.self,
  })
end

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
  {spell = 2580, texture = 136025},  -- Find Minerals
  {spell = 2383, texture = 133939},  -- Find Herbs
}

local conjuredb = {
  -- waters
  {
    count = 40,
    spells = {
      {spell = 10140, item = 8079},
      {spell = 10139, item = 8078},
      {spell = 10138, item = 8077},
      {spell = 6127, item = 3772},
      {spell = 5506, item = 2136},
      {spell = 5505, item = 2288},
      {spell = 5504, item = 5350},
    },
  },
  -- managems
  {
    count = 1,
    spells = {
      {spell = 10054, item = 8008},
      {spell = 10053, item = 8007},
      {spell = 3552, item = 5513},
      {spell = 759, item = 5514},
    },
  },
  -- healthstones
  {
    count = 1,
    spells = {
      {spell = 11730, item = 9421},
      {spell = 11729, item = 5510},
      {spell = 5699, item = 5509},
      {spell = 6202, item = 5511},
      {spell = 6201, item = 5512},
    },
  },
}

local function canCast(spell, unit)
  return IsSpellKnown(spell.id)
      and spell.level - 10 <= UnitLevel(unit)
      and (not spell.reagent or GetItemCount(spell.reagent) > 0)
end

local function GetBuffToCast(unit)
  local buffs = GetUnitBuffs(unit)
  for _, slot in ipairs(thebuffdb) do
    local id = (function()
      if slot.self and unit ~= 'player' then
        return nil
      end
      for _, buff in ipairs(slot.buffs) do
        local id, skip = (function()
          if buff.classes then
            local unitClass = UnitClass(unit)
            local found = false
            for _, class in ipairs(buff.classes) do
              found = found or unitClass == class
            end
            if not found then
              return nil
            end
          end
          if buff.tank ~= nil
              and buff.tank ~= UnitIsUnit(unit, G.TheTankUnit) then
            return nil
          end
          if buff.flag and not G[buff.flag] then
            return nil
          end
          if buff.party and not UnitInParty(unit) then
            return nil
          end
          for _, rank in ipairs(buff.ranks) do
            local spell = rank.spell
            local group = rank.group
            if buffs[spell.id] or group and buffs[group.id] then
              return nil, true
            end
            if group and canCast(group, unit) then
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

local unitsToBuff = {
  'player',
  'party1',
  'party2',
  'party3',
  'party4',
  'target',
}

local function GetSpellToCast()
  for _, track in ipairs(trackingdb) do
    if IsSpellKnown(track.spell) and GetTrackingTexture() ~= track.texture then
      return track.spell, 'player'
    end
  end
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
end

G.PreClickButton('PartyBuffButton', '', function()
  local spell, unit = GetSpellToCast()
  if not spell then
    return nil, 'shrug'
  end
  if GetSpellCooldown(spell) ~= 0 then
    return nil, 'yawn'
  end
  local _, nomana = IsUsableSpell(spell)
  if nomana then
    return nil, 'oom'
  end
  local spellName, _, _, castTime = GetSpellInfo(spell)
  if castTime > 0 and GetUnitSpeed('player') > 0 then
    return nil, 'crack'
  end
  local subtext = GetSpellSubtext(spell)
  if subtext then
    spellName = spellName..'('..subtext..')'
  end
  return '/stand\n/cancelform\n/cast [@'.. unit..']'..spellName
end)

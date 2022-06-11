local _, G = ...

local scan = (function()
  local name = 'FerronnizerScannerTooltip'
  local leftPrefix = name .. 'TextLeft'
  local scanner = CreateFrame('GameTooltip', name, nil, 'SharedTooltipTemplate')
  scanner:SetOwner(WorldFrame, 'ANCHOR_NONE')

  local function num(field, patt)
    return {
      func = tonumber,
      field = field,
      pattern = patt,
    }
  end

  local patterns = {
    num('Agility', '([+-]%d+) Agility'),
    num('AttackPower', '([+-]%d+) Attack Power'),
    num('Defense', '([+-]%d+) Defense'),
    num('Defense', 'Increased Defense ([+-]%d+)'),
    num('FireResistance', '([+-]%d+) Fire Resistance'),
    num('FrostResistance', '([+-]%d+) Frost Resistance'),
    num('HealingPower', '([+-]%d+) Healing Spells'),
    num('HealingPower', 'Healing Spells ([+-]%d+)'),
    num('Intellect', '([+-]%d+) Intellect'),
    num('ShadowResistance', '([+-]%d+) Shadow Resistance'),
    num('Spirit', '([+-]%d+) Spirit'),
    num('Stamina', '([+-]%d+) Stamina'),
    num('Strength', '([+-]%d+) Strength'),
    num('Armor', '(%d+) Armor'),
    num('DPS', '%(([%d%.]+) damage per second%)'),
    num('HealingPower', 'Equip: Increases healing done by spells and effects by up to (%d+).'),
    num('PhysicalCrit', 'Equip: Improves your chance to get a critical strike by (%d+)%%.'),
    num('PhysicalHit', 'Equip: Improves your chance to hit by (%d+)%%.'),
    num('HP5', 'Equip: Restores (%d+) health per 5 sec.'),
    num('MP5', 'Equip: Restores (%d+) mana per 5 sec.'),
    num('SpellCrit', 'Equip: Improves your chance to get a critical strike with spells by (%d+)%%.'),
    num('SpellPower', 'Equip: Increases damage and healing done by magical spells and effects by up to (%d+).'),
  }

  local function process(func, arg, ...)
    if arg then
      return func(arg, ...)
    end
  end

  local cache = {}
  return function(link)
    local cached = cache[link]
    if cached then
      return cached
    end
    scanner:SetHyperlink(link)
    local stats = {}
    for i = 1, scanner:NumLines() do
      local text = _G[leftPrefix .. i]:GetText()
      for _, p in ipairs(patterns) do
        local v = process(p.func, text:match(p.pattern))
        if v then
          stats[p.field] = (stats[p.field] or 0) + v
        end
      end
    end
    scanner:ClearLines()
    cache[link] = stats
    return stats
  end
end)()

G.DataWatch('equipment', function(equipment)
  local t = {}
  for _, link in pairs(equipment) do
    for k, v in pairs(scan(link)) do
      t[k] = (t[k] or 0) + v
    end
  end
  DevTools_Dump(t)
end)

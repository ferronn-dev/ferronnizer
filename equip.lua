local scan = (function()
  local name = 'FerronnizerScannerTooltip'
  local leftPrefix = name .. 'TextLeft'
  local scanner = CreateFrame('GameTooltip', name, nil, 'SharedTooltipTemplate')
  scanner:SetOwner(WorldFrame, 'ANCHOR_NONE')

  local patterns = {
    {
      pattern = '([+-])(%d+) (%a+)',
      func = (function()
        local supported = {
          Agility = true,
          Intellect = true,
          Spirit = true,
          Stamina = true,
          Strength = true,
        }
        return function(t, p, v, s)
          if supported[s] then
            t[s] = (p == '+' and 1 or -1) * tonumber(v)
          end
        end
      end)(),
    },
    {
      pattern = '%((%d+).(%d) damage per second%)',
      func = function(t, dps1, dps2)
        t.DPS = tonumber(dps1 .. '.' .. dps2)
      end,
    },
    {
      pattern = '(%d+) Armor',
      func = function(t, armor)
        t.Armor = tonumber(armor)
      end,
    },
    {
      pattern = '%+(%d+) Healing Spells',
      func = function(t, hp)
        t.HealingPower = tonumber(hp)
      end,
    },
    {
      pattern = 'Equip: Increases damage and healing done by magical spells and effects by up to (%d+).',
      func = function(t, sp)
        t.SpellPower = tonumber(sp)
      end,
    },
    {
      pattern = 'Equip: Increases healing done by spells and effects by up to (%d+).',
      func = function(t, hp)
        t.HealingPower = tonumber(hp)
      end,
    },
    {
      pattern = 'Equip: Improves your chance to get a critical strike with spells by (%d)%%.',
      func = function(t, sc)
        t.SpellCrit = tonumber(sc)
      end,
    },
    {
      pattern = 'Equip: Restores (%d+) mana per 5 sec.',
      func = function(t, mp5)
        t.MP5 = tonumber(mp5)
      end,
    },
    {
      pattern = 'Equip: Restores (%d+) health per 5 sec.',
      func = function(t, hp5)
        t.HP5 = tonumber(hp5)
      end,
    },
  }

  local function process(func, stats, arg, ...)
    if arg then
      func(stats, arg, ...)
    end
  end

  return function(slot)
    scanner:SetInventoryItem('player', slot)
    local stats = {}
    for i = 1, scanner:NumLines() do
      local text = _G[leftPrefix .. i]:GetText()
      for _, p in ipairs(patterns) do
        process(p.func, stats, text:match(p.pattern))
      end
    end
    scanner:ClearLines()
    return stats
  end
end)()

local t = {}
for i = 0, 19 do
  for k, v in pairs(scan(i)) do
    t[k] = (t[k] or 0) + v
  end
end
DevTools_Dump(t)

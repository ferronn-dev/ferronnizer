local _, G = ...

-- TODO update addonmaker
local hacks = {
  GameTime_GetTime = function() end,
  GetMaxPlayerLevel = function() end,
  GetPetHappiness = function() end,
  GetServerTime = function() end,
  IsResting = function() end,
  UnitGetIncomingHeals = function()
    return 0
  end,
}
for k, v in pairs(hacks) do
  if _G[k] == nil then
    _G[k] = v
  end
end

local entries = {
  game_time = {
    init = '',
    update = function()
      return true, _G.GameTime_GetTime(false)
    end,
  },
  max_player_level = {
    init = _G.GetMaxPlayerLevel(),
    events = {
      PLAYER_MAX_LEVEL_UPDATE = function()
        return true, _G.GetMaxPlayerLevel()
      end,
    },
  },
  pet_happiness = {
    init = '',
    events = {
      UNIT_HAPPINESS = function(u)
        if u ~= 'pet' then
          return false
        else
          return true, _G.GetPetHappiness()
        end
      end,
    },
  },
  player_on_hate_list = {
    init = false,
    events = {
      PLAYER_REGEN_DISABLED = function()
        return true, true
      end,
      PLAYER_REGEN_ENABLED = function()
        return true, false
      end,
    },
  },
  player_resting = {
    init = _G.IsResting(),
    events = {
      PLAYER_UPDATE_RESTING = function()
        return true, _G.IsResting()
      end,
    },
  },
  server_time = {
    init = GetServerTime(),
    update = function()
      return true, GetServerTime()
    end,
  },
  skill_table = {
    init = {},
    events = (function()
      local function compute()
        local t = {}
        for i = 1, GetNumSkillLines() do
          local name, _, _, value = GetSkillLineInfo(i)
          if name == PROFESSIONS_FIRST_AID then
            t['firstaid'] = value
          end
        end
        return true, t
      end
      return {
        CHAT_MSG_SKILL = compute,
        PLAYER_LOGIN = compute,
      }
    end)(),
  },
}

local function getAuras(unit, filter)
  local t = {}
  local index = 1
  while true do
    local _, icon, count, dispelType, duration, expiration = UnitAura(unit, index, filter)
    if not icon then
      break
    end
    table.insert(t, {
      count = count,
      dispelType = dispelType,
      duration = duration,
      expiration = expiration,
      icon = icon,
    })
    index = index + 1
  end
  return t
end

local unitTokens = {
  focus = { 'PLAYER_FOCUS_CHANGED' },
  pet = { 'UNIT_PET' },
  player = {},
  target = { 'PLAYER_TARGET_CHANGED' },
}
for i = 1, 4 do
  unitTokens['party' .. i] = { 'GROUP_ROSTER_UPDATE' }
end
for i = 1, 40 do
  unitTokens['nameplate' .. i] = { 'NAME_PLATE_UNIT_ADDED' }
end
local unitEntries = {
  buffs = {
    func = function(unit)
      return getAuras(unit, 'HELPFUL')
    end,
    events = { 'UNIT_AURA' },
  },
  class = {
    func = UnitClassBase,
    events = {},
  },
  debuffs = {
    func = function(unit)
      return getAuras(unit, 'HARMFUL')
    end,
    events = { 'UNIT_AURA' },
  },
  health = {
    func = UnitHealth,
    events = { 'UNIT_HEALTH', 'UNIT_HEALTH_FREQUENT' },
  },
  incoming_heals = {
    func = _G.UnitGetIncomingHeals,
    events = { 'UNIT_HEAL_PREDICTION' },
  },
  level = {
    func = UnitLevel,
    events = { 'UNIT_LEVEL' },
  },
  max_health = {
    func = UnitHealthMax,
    events = { 'UNIT_MAXHEALTH' },
  },
  max_power = {
    func = UnitPowerMax,
    events = { 'UNIT_POWER_UPDATE' },
  },
  max_xp = {
    func = UnitXPMax,
    events = { 'PLAYER_XP_UPDATE' },
    units = { player = true },
  },
  name = {
    func = UnitName,
    events = { 'UNIT_NAME_UPDATE' },
  },
  power = {
    func = UnitPower,
    events = { 'UNIT_POWER_UPDATE' },
  },
  power_type = {
    func = function(unit)
      return select(2, UnitPowerType(unit))
    end,
    events = { 'UNIT_POWER_UPDATE' },
  },
  xp = {
    func = UnitXP,
    events = { 'PLAYER_XP_UPDATE' },
    units = { player = true },
  },
}
for unit, events in pairs(unitTokens) do
  for name, entry in pairs(unitEntries) do
    if not entry.units or entry.units[unit] then
      local func = entry.func
      local unconditional = function()
        return true, func(unit)
      end
      local handlers = {
        PLAYER_LOGIN = unconditional,
      }
      for _, event in ipairs(entry.events) do
        handlers[event] = function(u)
          if u ~= unit then
            return false
          else
            return true, func(unit)
          end
        end
      end
      for _, event in ipairs(events) do
        handlers[event] = unconditional
      end
      entries[unit .. '_' .. name] = {
        init = func(unit),
        events = handlers,
      }
    end
  end
end

local handlers = {}
local pending = {}
local updates = {}
local values = {}
local watches = {}
local watchnames = {}

for k, v in pairs(entries) do
  watches[k] = {}
  updates[k] = v.update
  values[k] = v.init
  for e, h in pairs(v.events or {}) do
    handlers[e] = handlers[e] or {}
    handlers[e][k] = h
  end
end

local function process(name, useValue, newValue)
  if useValue and values[name] ~= newValue then
    values[name] = newValue
    pending[name] = true
  end
end

local function invoke(func)
  local names = watchnames[func]
  local vals = {}
  for i, name in ipairs(names) do
    vals[i] = values[name]
  end
  func(unpack(vals, 1, #names))
end

local frame = CreateFrame('Frame')
frame:SetScript('OnEvent', function(_, ev, ...)
  for k, v in pairs(handlers[ev]) do
    process(k, v(...))
  end
end)
for e in pairs(handlers) do
  frame:RegisterEvent(e)
end
frame:SetScript('OnUpdate', function()
  for k, v in pairs(updates) do
    process(k, v())
  end
  local funcs = {}
  for name in pairs(pending) do
    for _, func in ipairs(watches[name]) do
      funcs[func] = true
    end
    pending[name] = nil
  end
  for func in pairs(funcs) do
    invoke(func)
  end
end)

local numFrameWatches = 0

function G.AddFrameWatch(f)
  assert(f:GetScript('OnEnter') == nil)
  assert(f:GetScript('OnLeave') == nil)
  numFrameWatches = numFrameWatches + 1
  local tag = '_framewatch_' .. numFrameWatches
  watches[tag] = {}
  values[tag] = false
  f:SetScript('OnEnter', function()
    values[tag] = true
    pending[tag] = true
  end)
  f:SetScript('OnLeave', function()
    values[tag] = false
    pending[tag] = true
  end)
  return tag
end

function G.DataWatch(...)
  local n = select('#', ...)
  local func = select(n, ...)
  assert(type(func) == 'function')
  local names = {}
  for i = 1, n - 1 do
    local name = select(i, ...)
    assert(type(name) == 'string')
    assert(watches[name], 'invalid watch for ' .. tostring(name))
    table.insert(watches[name], func)
    table.insert(names, name)
  end
  watchnames[func] = names
  invoke(func)
end

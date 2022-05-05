local _, G = ...

-- TODO update addonmaker
local hacks = {
  GameTime_GetTime = function() end,
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
}

local unitTokens = {
  focus = { 'PLAYER_FOCUS_CHANGED' },
  party1 = { 'GROUP_ROSTER_UPDATE' },
  party2 = { 'GROUP_ROSTER_UPDATE' },
  party3 = { 'GROUP_ROSTER_UPDATE' },
  party4 = { 'GROUP_ROSTER_UPDATE' },
  pet = {},
  player = {},
  target = { 'PLAYER_TARGET_CHANGED' },
}
local unitEntries = {
  class = {
    func = UnitClassBase,
    events = {},
  },
  health = {
    func = UnitHealth,
    events = { 'UNIT_HEALTH', 'UNIT_HEALTH_FREQUENT' },
  },
  level = {
    func = UnitLevel,
    events = { 'UNIT_NAME_UPDATE' },
  },
  max_health = {
    func = UnitHealthMax,
    events = { 'UNIT_MAXHEALTH' },
  },
  max_power = {
    func = UnitPowerMax,
    events = { 'UNIT_POWER_UPDATE' },
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
}
for unit, events in pairs(unitTokens) do
  for name, entry in pairs(unitEntries) do
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

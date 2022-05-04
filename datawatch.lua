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
  'focus',
  'party1',
  'party2',
  'party3',
  'party4',
  'pet',
  'player',
  'target',
}
for _, unit in ipairs(unitTokens) do
  local unitEntries = {
    level = {
      init = UnitLevel(unit),
      events = {
        UNIT_NAME_UPDATE = function(u)
          if u ~= unit then
            return false
          else
            return true, UnitLevel(unit)
          end
        end,
      },
    },
    name = {
      init = UnitName(unit),
      events = {
        UNIT_NAME_UPDATE = function(u)
          if u ~= unit then
            return false
          else
            return true, UnitName(unit)
          end
        end,
      },
    },
  }
  for k, v in pairs(unitEntries) do
    entries[unit .. '_' .. k] = v
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

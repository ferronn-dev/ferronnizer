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

local callbacks = {}
local handlers = {}
local updates = {}
local values = {}

function G.DataWatch(name, callback)
  assert(callbacks[name], 'invalid watch for ' .. tostring(name))
  table.insert(callbacks[name], callback)
  callback(values[name])
end

for k, v in pairs(entries) do
  callbacks[k] = {}
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
    for _, cb in ipairs(callbacks[name]) do
      cb(newValue)
    end
  end
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
end)

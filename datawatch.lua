local _, G = ...

local entries = {
  game_time = {
    init = '',
    update = function()
      return _G.GameTime_GetTime(false)
    end,
  },
  player_level = {
    init = UnitLevel('player'),
    events = {
      PLAYER_LEVEL_UP = function(level)
        return level
      end,
    },
  },
  player_name = {
    init = UnitName('player'),
  },
}

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

local function process(name, newValue)
  if values[name] ~= newValue then
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

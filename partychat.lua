local _, G = ...

local chat_prefix = 'FerronnizerPChat'
C_ChatInfo.RegisterAddonMessagePrefix(chat_prefix)
local callbacks = {}
local registrationEnabled = true

G.Eventer({
  ADDON_LOADED = function()
    registrationEnabled = false
  end,
  CHAT_MSG_ADDON = function(prefix, text, _, sender)
    if prefix ~= chat_prefix then
      return
    end
    local senderName = string.match(sender, '^([^-]*)')
    local parts = {strsplit(':', text)}
    local cmd = tonumber(table.remove(parts, 1))
    callbacks[cmd](senderName, unpack(parts))
  end
})

function G.RegisterPartyChat(recv)
  assert(registrationEnabled)
  table.insert(callbacks, recv)
  local cmd = #callbacks
  return function(...)
    if IsInGroup() then
      ChatThrottleLib:SendAddonMessage(
          'NORMAL', chat_prefix, table.concat({cmd, ...}, ':'), 'PARTY')
    else
      callbacks[cmd](UnitName('player'), ...)
    end
  end
end

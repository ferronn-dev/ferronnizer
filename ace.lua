local addonName, G = ...

local ace = LibStub('AceAddon-3.0'):NewAddon(addonName, 'AceComm-3.0', 'AceConsole-3.0', 'AceSerializer-3.0')

LibStub('AceConfig-3.0'):RegisterOptionsTable(addonName, {
  type = 'group',
  args = {
    frames = (function()
      local state = true
      return {
        name = 'Frames',
        desc = 'Toggles Blizzard raid frames',
        type = 'toggle',
        get = function()
          return state
        end,
        set = function(_, value)
          local root = _G.FerronnizerRoot
          local hidden = root.Hidden
          state = value
          CompactRaidFrameManager:SetParent(state and hidden or UIParent)
          for i = 1, 4 do
            root['Party' .. i]:SetParent(state and root or hidden)
          end
        end,
      }
    end)(),
  },
})
local slash = 'ferronnizer'
local handleCommand = LibStub('AceConfigCmd-3.0').HandleCommand
ace:RegisterChatCommand(slash, function(input)
  handleCommand(ace, slash, addonName, input)
end)

local commWatches = {
  'following',
  'on_hate_list',
  'resting',
}

local pubs = {}
for i = 1, 4 do
  local prefix = 'party' .. i .. '_'
  local t = {}
  for _, w in ipairs(commWatches) do
    t[w] = G.RegisterDataWatch(prefix .. w)
  end
  table.insert(pubs, t)
end
ace:RegisterComm(addonName, function(_, msg, _, sender)
  for i = 1, 4 do
    if UnitIsUnit(sender, 'party' .. i) then
      local _, t = assert(ace:Deserialize(msg))
      for k, v in pairs(pubs[i]) do
        v(t[k])
      end
    end
  end
end)
local wargs = {}
for _, w in ipairs(commWatches) do
  table.insert(wargs, 'player_' .. w)
end
table.insert(wargs, function(...)
  local t = {}
  for i, w in ipairs(commWatches) do
    t[w] = select(i, ...)
  end
  ace:SendCommMessage(addonName, ace:Serialize(t), 'PARTY')
end)
G.DataWatch(unpack(wargs))

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

local pubs = {}
for i = 1, 4 do
  table.insert(pubs, G.RegisterDataWatch(('party%d_resting'):format(i)))
end
ace:RegisterComm(addonName, function(_, value, _, sender)
  for i = 1, 4 do
    if UnitIsUnit(sender, 'party' .. i) then
      pubs[i](value == 'true')
    end
  end
end)
G.DataWatch('player_resting', function(value)
  ace:SendCommMessage(addonName, tostring(value), 'PARTY')
end)

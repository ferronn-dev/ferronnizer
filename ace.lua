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
        set = (function()
          local root = _G.FerronnizerRoot
          local hidden = root.Hidden
          return function(_, value)
            state = value
            CompactRaidFrameManager:SetParent(state and hidden or UIParent)
            for i = 1, 4 do
              root['Party' .. i]:SetParent(state and root or hidden)
            end
          end
        end)(),
      }
    end)(),
  },
})
local slash = 'ferronnizer'
local handleCommand = LibStub('AceConfigCmd-3.0').HandleCommand
ace:RegisterChatCommand(slash, function(input)
  handleCommand(ace, slash, addonName, input)
end)

ace:RegisterComm(addonName, function(_, value, _, sender)
  print(('%s is following %s.'):format(sender, value))
end)

G.DataWatch('following', function(value)
  ace:SendCommMessage(addonName, tostring(value), 'PARTY')
end)

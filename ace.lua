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
  local prefix = 'party' .. i .. '_'
  table.insert(pubs, {
    on_hate_list = G.RegisterDataWatch(prefix .. 'on_hate_list'),
    resting = G.RegisterDataWatch(prefix .. 'resting'),
  })
end
ace:RegisterComm(addonName, function(_, msg, _, sender)
  for i = 1, 4 do
    if UnitIsUnit(sender, 'party' .. i) then
      local _, t = assert(ace:Deserialize(msg))
      local p = pubs[i]
      p.on_hate_list(t.on_hate_list)
      p.resting(t.resting)
    end
  end
end)
G.DataWatch('player_on_hate_list', 'player_resting', function(on_hate_list, resting)
  local msg = ace:Serialize({
    on_hate_list = on_hate_list,
    resting = resting,
  })
  ace:SendCommMessage(addonName, msg, 'PARTY')
end)

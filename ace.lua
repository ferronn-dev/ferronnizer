local toggleRaidFrames = (function()
  local root = _G.FerronnizerRoot
  local frames = {
    [CompactRaidFrameManager] = UIParent,
    [root.Party1] = root,
    [root.Party2] = root,
    [root.Party3] = root,
    [root.Party4] = root,
  }
  local hidden = root.Hidden
  return function()
    for k, v in pairs(frames) do
      k:SetParent(k:GetParent() == v and hidden or v)
    end
  end
end)()

local ace = LibStub('AceAddon-3.0'):NewAddon('Ferronnizer', 'AceConsole-3.0')
ace:RegisterChatCommand('ferronnizer', function(str)
  if str == 'frames' then
    toggleRaidFrames()
  end
end)

local _, G = ...

local sendFollow = G.RegisterPartyChat(function(name)
  if not UnitIsUnit('player', name) then
    FollowUnit(name)
  end
end)

G.PreClickButton('FollowButton', '', function()
  sendFollow()
  return nil, 'follow'
end)

local _, G = ...

local sendFollow = G.RegisterPartyChat(function(name)
  if name ~= UnitName('player') then
    FollowUnit(name)
  end
end)

G.PreClickButton('FollowButton', '', function()
  sendFollow()
  return nil, 'follow'
end)

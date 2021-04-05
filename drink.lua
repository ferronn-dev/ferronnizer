local _, G = ...
G.PreClickButton('DrinkButton', '', function()
  local now = GetTime()
  for _, drink in ipairs(G.DrinkDB) do
    local item, buff = unpack(drink)
    if GetItemCount(item) > 0 then
      for i = 1, 40 do
        local _, _, _, _, _, exp, _, _, _, id = UnitBuff('player', i)
        if id == buff and exp - now > 3 then
          return nil, 'drink'
        end
      end
      FollowUnit('player')
      return '/use item:'..item
    end
  end
  return nil, 'thirsty'
end)

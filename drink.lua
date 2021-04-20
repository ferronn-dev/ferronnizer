local _, G = ...
local function consume(db, hasEmote, noEmote)
  local now = GetTime()
  for _, consumable in ipairs(db) do
    local item, buff = unpack(consumable)
    if GetItemCount(item) > 0 then
      for i = 1, 40 do
        local _, _, _, _, _, exp, _, _, _, id = UnitBuff('player', i)
        if id == buff and exp - now > 3 then
          return nil, hasEmote
        end
      end
      FollowUnit('player')
      return '/use item:'..item
    end
  end
  return nil, noEmote
end
G.PreClickButton('DrinkButton', '', function()
  return consume(G.DrinkDB, 'drink', 'thirsty')
end)
G.PreClickButton('EatButton', '', function()
  return consume(G.FoodDB, 'eat', 'hungry')
end)

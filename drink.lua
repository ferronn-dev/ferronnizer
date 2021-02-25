local _, G = ...
local waters = {
  { item = 8079, buff = 22734 },
  { item = 8078, buff = 1137 },
  { item = 8077, buff = 1135 },
  { item = 3772, buff = 1133 },
  { item = 2136, buff = 432 },
  { item = 2288, buff = 431 },
  { item = 5350, buff = 430 },
}
G.PreClickButton('DrinkButton', '', function()
  local now = GetTime()
  for _, water in ipairs(waters) do
    if GetItemCount(water.item) > 0 then
      for i = 1, 40 do
        local _, _, _, _, _, exp, _, _, _, id = UnitBuff('player', i)
        if id == water.buff and exp - now > 3 then
          return nil, 'drink'
        end
      end
      FollowUnit('player')
      return '/use item:'..water.item
    end
  end
  return nil, 'thirsty'
end)

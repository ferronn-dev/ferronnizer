local _, G = ...

local xpdata = {}

local send = G.RegisterPartyChat(function(...)
  local name, level, xp, xpmax, money, bagfree, bagtotal, durcur, durmax = ...
  xpdata[name] = {
    level = level,
    xp = xp,
    xpmax = xpmax,
    money = money,
    bagfree = bagfree,
    bagtotal = bagtotal,
    durcur = durcur,
    durmax = durmax,
  }
end)

local function SendInfoToParty()
  local level = UnitLevel('player')
  local xp = UnitXP('player')
  local xpmax = UnitXPMax('player')
  local money = GetMoney()
  local bagfree, bagtotal = 0, 0
  for i = 0, NUM_BAG_SLOTS do
    bagfree = bagfree + GetContainerNumFreeSlots(i)
    bagtotal = bagtotal + GetContainerNumSlots(i)
  end
  local durcur, durmax = 0, 0
  for invslot = 0, 19 do
    local cur, max = GetInventoryItemDurability(invslot)
    if cur and max then
      durcur = durcur + cur
      durmax = durmax + max
    end
  end
  send(level, xp, xpmax, money, bagfree, bagtotal, durcur, durmax)
end

G.Eventer({PLAYER_ENTERING_WORLD = SendInfoToParty})
C_Timer.NewTicker(15, SendInfoToParty)

function G.GetPlayerInfo(unit)
  return xpdata[unit]
end

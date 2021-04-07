local _, G = ...

local gearPlanner = LibStub('LibClassicGearPlanner')

local bags = {}
local equipment = {}
local talents = {}
local url = ''

local function getEquipment()
  local data = {}
  for i = 0, 19 do
    data[i] = GetInventoryItemLink('player', i)
  end
  return data
end

local function getTalents()
  if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then
    return nil
  end
  local tabs = {}
  for i = 1, GetNumTalentTabs() do
    local tals = {}
    for j = 1, GetNumTalents(i) do
      table.insert(tals, {GetTalentInfo(i, j)})
    end
    table.insert(tabs, tals)
  end
  return tabs
end

G.Eventer({
  BAG_UPDATE = function(n)
    bags[n] = (function()
      local bag = {}
      for i = 1, GetContainerNumSlots(n) do
        table.insert(bag, {GetContainerItemInfo(n, i)})
      end
      return bag
    end)()
  end,
  PLAYER_ENTERING_WORLD = function()
    equipment = getEquipment()
    talents = getTalents()
    url = gearPlanner:GenerateUrl()
  end,
  PLAYER_EQUIPMENT_CHANGED = function()
    equipment = getEquipment()
    url = gearPlanner:GenerateUrl()
  end,
  CHARACTER_POINTS_CHANGED = function()
    talents = getTalents()
    url = gearPlanner:GenerateUrl()
  end,
  PLAYER_LOGOUT = function()
    _G['FerronnizerPlayerData'] = {
      bags = bags,
      class = UnitClassBase('player'),
      equipment = equipment,
      level = UnitLevel('player'),
      name = UnitName('player'),
      race = UnitRace('player'),
      realm = GetRealmName(),
      talents = talents,
      url = url,
    }
  end,
})

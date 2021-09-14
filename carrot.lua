local _, G = ...

local carrots = { 25653, 11122 }

local nonCarrot = nil

local function equipCarrot()
  local equipped = GetInventoryItemID('player', 13)
  for _, t in ipairs(carrots) do
    if equipped == t then
      return
    elseif GetItemCount(t) > 0 then
      nonCarrot = equipped
      return EquipItemByName(t, 13)
    end
  end
end

local function unequipCarrot()
  if nonCarrot then
    EquipItemByName(nonCarrot, 13)
    nonCarrot = nil
  end
end

local function carrotIfMounted()
  if not InCombatLockdown() then
    return (IsMounted() and equipCarrot or unequipCarrot)()
  end
end

G.Eventer({
  BAG_UPDATE_DELAYED = carrotIfMounted,
  PLAYER_EQUIPMENT_CHANGED = carrotIfMounted,
  PLAYER_MOUNT_DISPLAY_CHANGED = carrotIfMounted,
  PLAYER_REGEN_DISABLED = unequipCarrot,
  PLAYER_REGEN_ENABLED = carrotIfMounted,
})

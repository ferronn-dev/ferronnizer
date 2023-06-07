local _, G = ...

local carrots = {
  [8] = { 2432 },
  [10] = { 2434 },
  [13] = { 25653, 11122 },
}

local nonCarrots = {}

local function equipCarrot(slot, itemids)
  local equipped = GetInventoryItemID('player', slot)
  for _, itemid in ipairs(itemids) do
    if equipped == itemid then
      return
    elseif GetItemCount(itemid) > 0 then
      nonCarrots[slot] = equipped
      EquipItemByName(itemid, slot)
      return
    end
  end
end

local function equipCarrots()
  for slot, itemids in pairs(carrots) do
    equipCarrot(slot, itemids)
  end
end

local function unequipCarrots()
  for slot, itemid in pairs(nonCarrots) do
    EquipItemByName(itemid, slot)
  end
  wipe(nonCarrots)
end

local function carrotIfMounted()
  if not InCombatLockdown() then
    return (IsMounted() and equipCarrots or unequipCarrots)()
  end
end

G.Eventer({
  BAG_UPDATE_DELAYED = carrotIfMounted,
  PLAYER_EQUIPMENT_CHANGED = carrotIfMounted,
  PLAYER_MOUNT_DISPLAY_CHANGED = carrotIfMounted,
  PLAYER_REGEN_ENABLED = carrotIfMounted,
})

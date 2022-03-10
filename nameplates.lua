local _, G = ...

local function createHealthFrame(np)
  local ht
  return { 'UNIT_HEALTH', 'UNIT_HEALTH_FREQUENT', 'UNIT_MAXHEALTH' }, function(unit)
    if not ht then
      ht = np.UnitFrame.healthBar:CreateFontString()
      ht:SetFontObject(NumberFont_Small)
      ht:SetPoint('CENTER')
    end
    local hp, hpm = UnitHealth(unit), UnitHealthMax(unit)
    ht:SetText(hp .. ' / ' .. hpm)
  end
end

local constructors = { createHealthFrame }

local nameplateData = {}

local function onCreate(np)
  local datas = {}
  for _, constructor in ipairs(constructors) do
    local events, func = constructor(np)
    local frame = CreateFrame('Frame')
    frame:SetScript('OnEvent', function(_, _, unit)
      func(unit)
    end)
    table.insert(datas, { frame = frame, events = events, func = func })
  end
  nameplateData[np] = datas
end

local function onAdd(unitToken)
  local np = C_NamePlate.GetNamePlateForUnit(unitToken)
  for _, data in ipairs(nameplateData[np]) do
    data.func(unitToken)
    for _, ev in ipairs(data.events) do
      data.frame:RegisterUnitEvent(ev, unitToken)
    end
  end
end

local function onRemove(unitToken)
  local np = C_NamePlate.GetNamePlateForUnit(unitToken)
  for _, data in ipairs(nameplateData[np]) do
    data.frame:UnregisterAllEvents()
  end
end

G.Eventer({
  NAME_PLATE_CREATED = onCreate,
  NAME_PLATE_UNIT_ADDED = onAdd,
  NAME_PLATE_UNIT_REMOVED = onRemove,
})

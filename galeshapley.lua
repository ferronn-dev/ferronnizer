local _, G = ...

local function asPrefList(a, b)
  local allList = true
  for _, x in pairs(a) do
    allList = allList and type(x) == 'table'
  end
  if allList then
    return a
  end
  local aa = {}
  for n, f in pairs(a) do
    local bns = {}
    for bn in pairs(b) do
      table.insert(bns, bn)
    end
    table.sort(bns, f)
    aa[n] = bns
  end
  return aa
end

local function asPrefFunction(a)
  local allFunc = true
  for _, x in pairs(a) do
    allFunc = allFunc and type(x) == 'function'
  end
  if allFunc then
    return a
  end
  local aa = {}
  for n, bns in pairs(a) do
    local ranks = {}
    for i, bn in ipairs(bns) do
      ranks[bn] = i
    end
    aa[n] = function(x, y)
      return ranks[x] < ranks[y]
    end
  end
  return aa
end

G.StableMarriage = function(men, women)
  local tmen = asPrefList(men, women)
  local fwomen = asPrefFunction(women, men)
  local freeMen = {}
  local nextPref = {}
  for man in pairs(tmen) do
    freeMen[man] = true
    nextPref[man] = 1
  end
  local engagements = {}
  local man = next(freeMen)
  while man do
    local prefs = tmen[man]
    local idx = nextPref[man]
    local woman = prefs[idx]
    nextPref[man] = idx + 1
    local fiance = engagements[woman] or man
    if fwomen[woman](man, fiance) then
      freeMen[fiance] = true
      fiance = man
    end
    engagements[woman] = fiance
    freeMen[fiance] = nil
    man = next(freeMen)
  end
  return engagements
end

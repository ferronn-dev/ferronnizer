local _, G = ...

G.StableMarriage = function(men, women)
  local freeMen = {}
  local nextPref = {}
  for man in pairs(men) do
    freeMen[man] = true
    nextPref[man] = 1
  end
  local suitorRanks = {}
  for woman, prefs in pairs(women) do
    local ranks = {}
    for i, man in ipairs(prefs) do
      ranks[man] = i
    end
    suitorRanks[woman] = ranks
  end
  local engagements = {}
  local man = next(freeMen)
  while man do
    local prefs = men[man]
    local idx = nextPref[man]
    local woman = prefs[idx]
    nextPref[man] = idx + 1
    local fiance = engagements[woman] or man
    local suitors = suitorRanks[woman]
    if suitors[man] < suitors[fiance] then
      freeMen[fiance] = true
      fiance = man
    end
    engagements[woman] = fiance
    freeMen[fiance] = nil
    man = next(freeMen)
  end
  return engagements
end

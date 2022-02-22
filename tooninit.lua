local _, G = ...
G.ClassActionSpecs = {}
G.AddClassActionSpec = function(expansion, name, ...)
  if
    WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and expansion == 'Vanilla'
    or WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC and expansion == 'TBC'
  then
    G.ClassActionSpecs[name] = { ... }
  end
end

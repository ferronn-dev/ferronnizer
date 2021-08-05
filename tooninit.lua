local _, G = ...
G.Characters = {}
G.AddCharacter = function(expansion, name, spec)
  if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and expansion == 'Vanilla' or
      WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC and expansion == 'TBC' then
    G.Characters[name] = spec
  end
end

local _, G = ...
local spells = {23214, 13819}
local items = {8631, 8595, 8563, 13321, 18778}
local function GetMount()
  for _, spell in ipairs(spells) do
    if IsSpellKnown(spell) then
      return spell, nil
    end
  end
  for _, item in ipairs(items) do
    if GetItemCount(item) > 0 then
      return nil, item
    end
  end
end

G.PreClickButton('MountButton', '/dismount', function()
  if IsMounted() then
    return '/dismount'
  end
  local spell, item = GetMount()
  if item then
    if GetItemCooldown(item) ~= 0 then
      return nil, 'yawn'
    end
    return '/stand\n/cancelform\n/use item:'..item
  elseif spell then
    if GetSpellCooldown(spell) ~= 0 then
      return nil, 'yawn'
    end
    local usable, nomana = IsUsableSpell(spell)
    if nomana then
      return nil, 'oom'
    end
    if not usable then
      return nil, 'cry'
    end
    return '/stand\n/cancelform\n/cast '..GetSpellInfo(spell)
  else
    return nil, 'shrug'
  end
end)

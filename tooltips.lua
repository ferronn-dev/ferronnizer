local tooltipRefs = {
  GameTooltip,
  ItemRefTooltip,
  ShoppingTooltip1,
  ShoppingTooltip2,
  ShoppingTooltip3,
}

local scriptHooks = {
  Item = function(t)
    local _, link = t:GetItem()
    if not link then
      return
    end
    local _, _, _, ilvl, _, _, _, stack, _, texture, price = GetItemInfo(link)
    local shown = t.shownMoneyFrames
    if price and price > 0 and not (shown and shown > 0) then
      local count = 1
      local m = GetMouseFocus()
      if m and type(m.count) == 'number' and m.count > 1 then
        count = m.count
      end
      SetTooltipMoney(t, count * price)
    end
    local ilvlstr = nil
    if ilvl and ilvl > 0 then
      ilvlstr = 'ilvl '..ilvl
    end
    local stackstr = nil
    if stack and stack > 1 then
      stackstr = '/'..stack
    end
    if ilvlstr or stackstr then
      t:AddDoubleLine(ilvlstr, stackstr)
    end
    local id = select(2, strsplit(':', link))
    if id and texture then
      t:AddDoubleLine('id '..id, 'texture '..texture)
    end
  end,
  Spell = function(t)
    local _, id = t:GetSpell()
    if not id then
      return
    end
    local texture = select(3, GetSpellInfo(id))
    if not texture then
      return
    end
    t:AddDoubleLine('id '..id, 'texture '..texture)
  end,
}

local funcHooks = {
  UnitAura = function(t, unit, idx, filter)
    local _, tex, _, _, _, _, _, _, _, id = UnitAura(unit, idx, filter)
    if id and tex then
      t:AddDoubleLine('id '..id, 'texture '..tex)
      t:Show()
    end
  end,
  UnitBuff = function(t, unit, idx)
    local _, tex, _, _, _, _, _, _, _, id = UnitBuff(unit, idx)
    if id and tex then
      t:AddDoubleLine('id '..id, 'texture '..tex)
      t:Show()
    end
  end,
  UnitDebuff = function(t, unit, idx)
    local _, tex, _, _, _, _, _, _, _, id = UnitDebuff(unit, idx)
    if id and tex then
      t:AddDoubleLine('id '..id, 'texture '..tex)
      t:Show()
    end
  end,
}

for _, t in ipairs(tooltipRefs) do
  for k, v in pairs(scriptHooks) do
    assert(t:HookScript('OnTooltipSet'..k, v))
  end
  for k, v in pairs(funcHooks) do
    hooksecurefunc(t, 'Set'..k, v)
  end
end

local _, G = ...

local healthTexts = {}
for i = 1, 40 do
  local unit = 'nameplate' .. i
  G.DataWatch(unit .. '_health', unit .. '_max_health', function(health, healthMax)
    local np = C_NamePlate.GetNamePlateForUnit(unit)
    if np then
      local ht = healthTexts[np]
      if not ht then
        ht = np.UnitFrame.healthBar:CreateFontString()
        ht:SetFontObject(NumberFont_Small)
        ht:SetPoint('CENTER')
        healthTexts[np] = ht
      end
      ht:SetText(health .. ' / ' .. healthMax)
    end
  end)
end

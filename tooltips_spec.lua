describe('tooltips', function()
  it('does not crash on SetItem', function()
    local t = wow.env.GameTooltip
    t:SetItem(11122)
    assert.same({}, t.lines)
  end)
  it('does not crash on SetSpell', function()
    local t = wow.env.GameTooltip
    t:SetSpell(13819)
    assert.same({}, t.lines)
  end)
end)

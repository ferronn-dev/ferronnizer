describe('tooltips', function()
  it('render health/power on player', function()
    local state = require('addonloader')()
    local t = state.frames['GameTooltip']
    t:SetUnit('player')
    local expected = {
      {l = 'Health', r = '1500/2000 (75.0%)'},
      {l = 'Power', r = '1000/1250 (80.0%)'},
    }
    assert.same(expected, t.lines)
  end)
  it('does not crash on SetItem', function()
    local state = require('addonloader')()
    local t = state.frames['GameTooltip']
    t:SetItem(11122)
    assert.same({}, t.lines)
  end)
  it('does not crash on SetSpell', function()
    local state = require('addonloader')()
    local t = state.frames['GameTooltip']
    t:SetSpell(13819)
    assert.same({}, t.lines)
  end)
end)

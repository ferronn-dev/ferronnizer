local T = require('testing')

T.RunTests({
  function(state)
    local t = state.frames['GameTooltip']
    t:SetUnit('player')
    local expected = {
      {l = 'Health', r = '1500/2000 (75.0%)'},
      {l = 'Power', r = '1000/1250 (80.0%)'},
    }
    T.assertEquals(expected, t.lines)
  end,
  function(state)
    local t = state.frames['GameTooltip']
    t:SetItem(11122)
    T.assertEquals({}, t.lines)
  end,
  function(state)
    local t = state.frames['GameTooltip']
    t:SetSpell(13819)
    T.assertEquals({}, t.lines)
  end,
})

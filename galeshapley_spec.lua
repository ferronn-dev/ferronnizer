local stableMarriage = (function()
  local env = {}
  loadfile('galeshapley.lua')('', env)
  return env.StableMarriage
end)()

describe('galeshapley', function()

  it('works on empty', function()
    assert.same({}, stableMarriage({}, {}))
  end)

  it('works on no men', function()
    assert.same({}, stableMarriage({}, { a = {} }))
  end)

  it('fails on no women', function()
    assert.error(function() stableMarriage({ a = {} }, {}) end)
  end)

  it('works on singletons', function()
    assert.same({ w1 = 'm1' }, stableMarriage({ m1 = { 'w1' } }, { w1 = { 'm1' } }))
  end)

  it('works on one man two women', function()
    local men = { m1 = { 'w1', 'w2' } }
    local women = { w1 = { 'm1' }, w2 = { 'm1' } }
    assert.same({ w1 = 'm1' }, stableMarriage(men, women))
  end)

  it('works on example from wikipedia', function()
    local men = {
      A = { 'Y', 'X', 'Z' },
      B = { 'Z', 'Y', 'X' },
      C = { 'X', 'Z', 'Y' },
    }
    local women = {
      X = { 'B', 'A', 'C' },
      Y = { 'C', 'B', 'A' },
      Z = { 'A', 'C', 'B' },
    }
    assert.same({ Y = 'A', Z = 'B', X = 'C' }, stableMarriage(men, women))
    assert.same({ A = 'Z', B = 'X', C = 'Y' }, stableMarriage(women, men))
  end)
end)

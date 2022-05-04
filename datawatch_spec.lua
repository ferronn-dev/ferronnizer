local function newDataWatch()
  local env = {}
  loadfile('datawatch.lua')('', env)
  return env.DataWatch
end

describe('datawatch', function()
  it('loads', function()
    -- TODO newDataWatch()
  end)
end)

local function newDataWatch()
  local data = {
    game_time = '4:20',
    units = {
      player = {
        class = 'WARRIOR',
        level = 60,
        name = 'PlayerName',
      },
    },
  }
  local scripts = {}
  local globalEnv = {
    assert = assert,
    CreateFrame = function()
      return {
        RegisterEvent = function() end,
        SetScript = function(self, name, script)
          scripts[name] = function(...)
            return script(self, ...)
          end
        end,
      }
    end,
    GameTime_GetTime = function()
      return data.game_time
    end,
    ipairs = ipairs,
    pairs = pairs,
    select = select,
    table = table,
    tostring = tostring,
    type = type,
    UnitClassBase = function(unit)
      return data.units[unit] and data.units[unit].class
    end,
    UnitLevel = function(unit)
      return data.units[unit] and data.units[unit].level
    end,
    UnitName = function(unit)
      return data.units[unit] and data.units[unit].name
    end,
    unpack = unpack,
  }
  globalEnv._G = globalEnv
  local addonEnv = {}
  setfenv(loadfile('datawatch.lua'), globalEnv)('', addonEnv)
  return addonEnv.DataWatch, scripts.OnEvent, scripts.OnUpdate, data
end

describe('datawatch', function()
  it('works with no registrations', function()
    local _, _, onUpdate = newDataWatch()
    onUpdate()
    onUpdate()
  end)

  it('handles game_time', function()
    local game_time = 'foo'
    local watch, _, onUpdate, data = newDataWatch()
    watch('game_time', function(x)
      game_time = x
    end)
    assert.same('', game_time)
    onUpdate()
    assert.same('4:20', game_time)
    data.game_time = '5:35'
    onUpdate()
    assert.same('5:35', game_time)
  end)

  it('handles unit name', function()
    local watch, onEvent, onUpdate, data = newDataWatch()
    local player_name = 'foo'
    watch('player_name', function(x)
      player_name = x
    end)
    local focus_name = 'bar'
    watch('focus_name', function(x)
      focus_name = x
    end)
    assert.same('PlayerName', player_name)
    assert.Nil(focus_name)
    data.units.focus = { name = 'FocusName' }
    onEvent('UNIT_NAME_UPDATE', 'player')
    onUpdate()
    assert.same('PlayerName', player_name)
    assert.Nil(focus_name)
    onEvent('UNIT_NAME_UPDATE', 'focus')
    onUpdate()
    assert.same('PlayerName', player_name)
    assert.same('FocusName', focus_name)
    data.units.focus = nil
    onEvent('PLAYER_FOCUS_CHANGED')
    onUpdate()
    assert.same('PlayerName', player_name)
    assert.Nil(focus_name)
  end)

  it('handles unit class', function()
    local watch, onEvent, onUpdate, data = newDataWatch()
    local player_class = 'foo'
    watch('player_class', function(class)
      player_class = class
    end)
    assert.same('WARRIOR', player_class)
    data.units.player.class = 'DRUID'
    onEvent('PLAYER_LOGIN')
    onUpdate()
    assert.same('DRUID', player_class)
  end)

  it('handles multiwatch', function()
    local watch, onEvent, onUpdate, data = newDataWatch()
    local player_name = 'foo'
    local game_time = 'bar'
    watch('player_name', 'game_time', function(name, time)
      player_name = name
      game_time = time
    end)
    assert.same('PlayerName', player_name)
    assert.same('', game_time)
    onUpdate()
    assert.same('PlayerName', player_name)
    assert.same('4:20', game_time)
    data.units.player.name = 'Hello'
    onEvent('UNIT_NAME_UPDATE', 'player')
    onUpdate()
    assert.same('Hello', player_name)
    assert.same('4:20', game_time)
  end)
end)

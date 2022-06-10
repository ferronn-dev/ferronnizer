local function newDataWatch()
  local data = {
    game_time = '4:20',
    skilllines = {},
    units = {
      player = {
        class = 'WARRIOR',
        health = 3000,
        healthMax = 3500,
        level = 60,
        name = 'PlayerName',
        power = 50,
        powerMax = 100,
        powerType = 'RAGE',
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
    GetMoney = function()
      return 0
    end,
    GetNumSkillLines = function()
      return #data.skilllines
    end,
    GetSkillLineInfo = function(i)
      return unpack(data.skilllines[i])
    end,
    GetUnitSpeed = function()
      return 0
    end,
    ipairs = ipairs,
    pairs = pairs,
    PROFESSIONS_FIRST_AID = 'First Aid',
    select = select,
    table = table,
    tostring = tostring,
    type = type,
    UnitAura = function() end,
    UnitClassBase = function(unit)
      return data.units[unit] and data.units[unit].class
    end,
    UnitHealth = function(unit)
      return data.units[unit] and data.units[unit].health
    end,
    UnitHealthMax = function(unit)
      return data.units[unit] and data.units[unit].healthMax
    end,
    UnitLevel = function(unit)
      return data.units[unit] and data.units[unit].level
    end,
    UnitName = function(unit)
      return data.units[unit] and data.units[unit].name
    end,
    UnitPower = function(unit)
      return data.units[unit] and data.units[unit].power
    end,
    UnitPowerMax = function(unit)
      return data.units[unit] and data.units[unit].powerMax
    end,
    UnitPowerType = function(unit)
      return data.units[unit] and data.units[unit].powerType
    end,
    UnitXP = function(unit)
      return data.units[unit] and data.units[unit].xp
    end,
    UnitXPMax = function(unit)
      return data.units[unit] and data.units[unit].xpMax
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

  it('handles skill_table', function()
    local watch, onEvent, onUpdate, data = newDataWatch()
    local skill_table
    watch('skill_table', function(t)
      skill_table = t
    end)
    assert.same({}, skill_table)
    data.skilllines = {
      {},
      { 'First Aid', nil, nil, 42 },
    }
    onEvent('PLAYER_LOGIN')
    onUpdate()
    assert.same({ firstaid = 42 }, skill_table)
    data.skilllines = {
      {},
      { 'First Aid', nil, nil, 43 },
    }
    onEvent('CHAT_MSG_SKILL')
    onUpdate()
    assert.same({ firstaid = 43 }, skill_table)
  end)
end)

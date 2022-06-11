local function newDataWatch()
  local data = {
    game_time = '4:20',
    skilllines = {},
    units = {
      player = {
        class = 'WARRIOR',
        name = 'PlayerName',
      },
    },
  }
  wow.env.Mixin(wow.env, {
    GameTime_GetTime = function()
      return data.game_time
    end,
    GetNumSkillLines = function()
      return #data.skilllines
    end,
    GetSkillLineInfo = function(i)
      return unpack(data.skilllines[i])
    end,
    UnitClassBase = function(unit)
      return data.units[unit] and data.units[unit].class
    end,
    UnitName = function(unit)
      return data.units[unit] and data.units[unit].name
    end,
  })
  local addonEnv = {}
  setfenv(loadfile('datawatch.lua'), wow.env)('', addonEnv)
  local frame = addonEnv._datawatch.frame
  local function onEvent(...)
    return frame:GetScript('OnEvent')(frame, ...)
  end
  local function onUpdate(...)
    return frame:GetScript('OnUpdate')(frame, ...)
  end
  return addonEnv.DataWatch, onEvent, onUpdate, data
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

  describe('newtopic', function()
    it('works', function()
      local log = {}
      local pub, sub = wow.addon._datawatch.newtopic()
      local s1 = sub(function(v)
        table.insert(log, 's1c:' .. tostring(v))
      end)
      table.insert(log, 's1r:' .. tostring(s1))
      pub(42)
      local s2 = sub(function(v)
        table.insert(log, 's2c:' .. tostring(v))
      end)
      table.insert(log, 's2r:' .. tostring(s2))
      pub(99)
      assert.same('s1r:nil,s1c:42,s2r:42,s1c:99,s2c:99', table.concat(log, ','))
    end)
  end)

  describe('multisub', function()
    local function fns()
      local tt = wow.addon._datawatch
      return tt.newtopic, tt.multisub, tt.pushsubs
    end
    it('works', function()
      local newtopic, multisub, pushsubs = fns()
      local pub1, sub1 = newtopic()
      local pub2, sub2 = newtopic()
      pub1(12)
      pub2(34)
      local a1, a2
      multisub({ sub1, sub2 }, function(v1, v2)
        a1 = v1
        a2 = v2
      end)
      assert.same(12, a1)
      assert.same(34, a2)
      local b1, b2
      multisub({ sub1, sub2 }, function(v1, v2)
        b1 = v1
        b2 = v2
      end)
      assert.same(12, b1)
      assert.same(34, b2)
      pub1(56)
      pub2(78)
      assert.same(12, a1)
      assert.same(34, a2)
      assert.same(12, b1)
      assert.same(34, b2)
      pushsubs()
      assert.same(56, a1)
      assert.same(78, a2)
      assert.same(56, b1)
      assert.same(78, b2)
      pub1(nil)
      pub2(nil)
      assert.same(56, a1)
      assert.same(78, a2)
      assert.same(56, b1)
      assert.same(78, b2)
      pushsubs()
      assert.same(nil, a1)
      assert.same(nil, a2)
      assert.same(nil, b1)
      assert.same(nil, b2)
    end)
  end)
end)

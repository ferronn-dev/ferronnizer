local _, G = ...

local function newtopic()
  local fns = {}
  local last
  local function publish(value)
    last = value
    for _, fn in ipairs(fns) do
      fn(value)
    end
  end
  local function subscribe(fn)
    table.insert(fns, fn)
    return last
  end
  return publish, subscribe
end

local multisub, pushsubs = (function()
  local pending = {}
  local pushes = {}
  local values = {}
  local function multisub(subs, fn)
    for _, sub in ipairs(subs) do
      values[sub] = sub(function(value)
        if values[sub] ~= value then
          values[sub] = value
          pending[fn] = true
        end
      end)
    end
    pushes[fn] = function()
      local t = {}
      for i, sub in ipairs(subs) do
        t[i] = values[sub]
      end
      fn(unpack(t, 1, #subs))
    end
    pushes[fn]()
  end
  local function pushsubs()
    for fn in pairs(pending) do
      pending[fn] = nil
      pushes[fn]()
    end
  end
  return multisub, pushsubs
end)()

local entries = {
  bank_open = {
    init = false,
    events = {
      BANKFRAME_CLOSED = function()
        return true, false
      end,
      BANKFRAME_OPENED = function()
        return true, true
      end,
    },
  },
  game_time = {
    init = '',
    update = function()
      return true, GameTime_GetTime(false)
    end,
  },
  mailbox_open = {
    init = false,
    events = {
      MAIL_CLOSED = function()
        return true, false
      end,
      MAIL_SHOW = function()
        return true, true
      end,
    },
  },
  max_player_level = {
    init = GetMaxPlayerLevel(),
    events = {
      PLAYER_MAX_LEVEL_UPDATE = function()
        return true, GetMaxPlayerLevel()
      end,
    },
  },
  money = {
    init = 0,
    events = {
      PLAYER_LOGIN = function()
        return true, GetMoney()
      end,
      PLAYER_MONEY = function()
        return true, GetMoney()
      end,
    },
  },
  mounted = {
    events = {
      PLAYER_LOGIN = function()
        return true, IsMounted()
      end,
      PLAYER_MOUNT_DISPLAY_CHANGED = function()
        return true, IsMounted()
      end,
    },
  },
  pet_happiness = {
    init = '',
    events = {
      UNIT_HAPPINESS = function(u)
        if u ~= 'pet' then
          return false
        else
          return true, GetPetHappiness()
        end
      end,
    },
  },
  player_on_hate_list = {
    init = false,
    events = {
      PLAYER_REGEN_DISABLED = function()
        return true, true
      end,
      PLAYER_REGEN_ENABLED = function()
        return true, false
      end,
    },
  },
  player_resting = {
    init = IsResting(),
    events = {
      PLAYER_UPDATE_RESTING = function()
        return true, IsResting()
      end,
    },
  },
  ready_check_in_progress = {
    init = false,
    events = {
      READY_CHECK = function()
        return true, true
      end,
      READY_CHECK_FINISHED = function()
        return true, false
      end,
    },
  },
  server_time = {
    init = GetServerTime(),
    update = function()
      return true, GetServerTime()
    end,
  },
  skill_table = {
    init = {},
    events = (function()
      local function compute()
        local t = {}
        for i = 1, GetNumSkillLines() do
          local name, _, _, value = GetSkillLineInfo(i)
          if name == PROFESSIONS_FIRST_AID then
            t['firstaid'] = value
          end
        end
        return true, t
      end
      return {
        CHAT_MSG_SKILL = compute,
        PLAYER_LOGIN = compute,
      }
    end)(),
  },
  speed = {
    init = 0,
    update = function()
      return true, GetUnitSpeed('player') * 100 / BASE_MOVEMENT_SPEED
    end,
  },
  stealthed = {
    events = {
      PLAYER_LOGIN = function()
        return true, IsStealthed()
      end,
      UPDATE_STEALTH = function()
        return true, IsStealthed()
      end,
    },
  },
  subzone = {
    init = GetSubZoneText(),
    events = {
      ZONE_CHANGED = function()
        return true, GetSubZoneText()
      end,
      ZONE_CHANGED_INDOORS = function()
        return true, GetSubZoneText()
      end,
      ZONE_CHANGED_NEW_AREA = function()
        return true, GetSubZoneText()
      end,
    },
  },
  tracking_texture = {
    events = {
      MINIMAP_UPDATE_TRACKING = function()
        return true, GetTrackingTexture()
      end,
      PLAYER_LOGIN = function()
        return true, GetTrackingTexture()
      end,
    },
  },
  zone = {
    init = GetZoneText(),
    events = {
      ZONE_CHANGED = function()
        return true, GetZoneText()
      end,
      ZONE_CHANGED_INDOORS = function()
        return true, GetZoneText()
      end,
      ZONE_CHANGED_NEW_AREA = function()
        return true, GetZoneText()
      end,
    },
  },
}

local bags = {
  bag0 = BACKPACK_CONTAINER,
  bank0 = BANK_CONTAINER,
}
for i = 1, NUM_BAG_SLOTS do
  bags['bag' .. i] = i
end
for i = 1, NUM_BANKBAGSLOTS do
  bags['bank' .. i] = NUM_BAG_SLOTS + i
end
for name, bagid in pairs(bags) do
  entries[name] = {
    init = {},
    events = (function()
      local function doUpdate()
        local t = {}
        for slot = 1, GetContainerNumSlots(bagid) do
          local link = GetContainerItemLink(bagid, slot)
          if link then
            table.insert(t, link)
          end
        end
        return true, t
      end
      local update = false
      return {
        BAG_UPDATE = function(id)
          update = update or (id == bagid)
        end,
        BAG_UPDATE_DELAYED = function()
          if update then
            update = false
            return doUpdate()
          end
        end,
        PLAYER_LOGIN = doUpdate,
      }
    end)(),
  }
end

local function getAuras(unit, filter)
  local t = {}
  local index = 1
  while true do
    local _, icon, count, dispelType, duration, expiration = UnitAura(unit, index, filter)
    if not icon then
      break
    end
    table.insert(t, {
      count = count,
      dispelType = dispelType,
      duration = duration,
      expiration = expiration,
      icon = icon,
    })
    index = index + 1
  end
  return t
end

local unitTokens = {
  focus = { 'PLAYER_FOCUS_CHANGED' },
  pet = { 'UNIT_PET' },
  player = {},
  target = { 'PLAYER_TARGET_CHANGED' },
}
for i = 1, 4 do
  unitTokens['party' .. i] = { 'GROUP_ROSTER_UPDATE' }
end
for i = 1, 40 do
  unitTokens['nameplate' .. i] = { 'NAME_PLATE_UNIT_ADDED' }
end
local unitEntries = {
  alive = {
    func = function(unit)
      return not UnitIsDeadOrGhost(unit)
    end,
    events = { 'UNIT_HEALTH' },
  },
  buffs = {
    func = function(unit)
      return getAuras(unit, 'HELPFUL')
    end,
    events = { 'UNIT_AURA' },
  },
  class = {
    func = UnitClassBase,
    events = {},
  },
  connected = {
    func = function(unit)
      return UnitIsConnected(unit) ~= false
    end,
    events = { 'UNIT_CONNECTION' },
  },
  debuffs = {
    func = function(unit)
      return getAuras(unit, 'HARMFUL')
    end,
    events = { 'UNIT_AURA' },
  },
  equipment = {
    events = { 'PLAYER_EQUIPMENT_CHANGED' },
    func = function(unit)
      local result = {}
      for i = 0, 18 do
        result[i] = GetInventoryItemLink(unit, i)
      end
      return result
    end,
    units = { player = true },
  },
  has_incoming_resurrection = {
    func = UnitHasIncomingResurrection,
    events = { 'INCOMING_RESURRECT_CHANGED' },
  },
  health = {
    func = UnitHealth,
    events = { 'UNIT_HEALTH', 'UNIT_HEALTH_FREQUENT' },
  },
  incoming_heals = {
    func = UnitGetIncomingHeals,
    events = { 'UNIT_HEAL_PREDICTION' },
  },
  level = {
    func = UnitLevel,
    events = { 'UNIT_LEVEL' },
  },
  max_health = {
    func = UnitHealthMax,
    events = { 'UNIT_MAXHEALTH' },
  },
  max_power = {
    func = UnitPowerMax,
    events = { 'UNIT_POWER_UPDATE' },
  },
  max_xp = {
    func = UnitXPMax,
    events = { 'PLAYER_XP_UPDATE' },
    units = { player = true },
  },
  name = {
    func = UnitName,
    events = { 'UNIT_NAME_UPDATE' },
  },
  power = {
    func = UnitPower,
    events = { 'UNIT_POWER_UPDATE' },
  },
  power_type = {
    func = function(unit)
      return select(2, UnitPowerType(unit))
    end,
    events = { 'UNIT_POWER_UPDATE' },
  },
  weapon_enchants = {
    func = (function()
      local function doProcess(hasEnchant, expiration, charges, enchantID)
        if hasEnchant then
          return {
            charges = charges,
            enchantID = enchantID,
            expiration = expiration,
          }
        end
      end
      local function process(...)
        return {
          [16] = doProcess(...),
          [17] = doProcess(select(5, ...)),
          [18] = doProcess(select(9, ...)),
        }
      end
      return function()
        return process(GetWeaponEnchantInfo())
      end
    end)(),
    events = { 'UNIT_INVENTORY_CHANGED' },
    units = { player = true },
  },
  xp = {
    func = UnitXP,
    events = { 'PLAYER_XP_UPDATE' },
    units = { player = true },
  },
}
for unit, events in pairs(unitTokens) do
  for name, entry in pairs(unitEntries) do
    if not entry.units or entry.units[unit] then
      local func = entry.func
      local unconditional = function()
        return true, func(unit)
      end
      local handlers = {
        PLAYER_LOGIN = unconditional,
      }
      for _, event in ipairs(entry.events) do
        handlers[event] = function(u)
          if u ~= unit then
            return false
          else
            return true, func(unit)
          end
        end
      end
      for _, event in ipairs(events) do
        handlers[event] = unconditional
      end
      entries[unit .. '_' .. name] = {
        init = func(unit),
        events = handlers,
      }
    end
  end
end

local handlers = {}
local topics = {}
local updates = {}

for k, v in pairs(entries) do
  local pub, sub = newtopic()
  topics[k] = sub
  updates[pub] = v.update
  pub(v.init)
  for e, h in pairs(v.events or {}) do
    handlers[e] = handlers[e] or {}
    handlers[e][pub] = h
  end
end

local function process(pub, useValue, newValue)
  if useValue then
    pub(newValue)
  end
end

local frame = CreateFrame('Frame')
frame:SetScript('OnEvent', function(_, ev, ...)
  for k, v in pairs(handlers[ev]) do
    process(k, v(...))
  end
end)
for e in pairs(handlers) do
  frame:RegisterEvent(e)
end
frame:SetScript('OnUpdate', function()
  for k, v in pairs(updates) do
    process(k, v())
  end
  pushsubs()
end)

local numFrameWatches = 0

function G.AddFrameWatch(f)
  assert(f:GetScript('OnEnter') == nil)
  assert(f:GetScript('OnLeave') == nil)
  numFrameWatches = numFrameWatches + 1
  local tag = '_framewatch_' .. numFrameWatches
  local pub, sub = newtopic()
  topics[tag] = sub
  f:SetScript('OnEnter', function()
    pub(true)
  end)
  f:SetScript('OnLeave', function()
    pub(false)
  end)
  return tag
end

function G.DataWatch(...)
  local n = select('#', ...)
  local func = select(n, ...)
  assert(type(func) == 'function')
  local subs = {}
  for i = 1, n - 1 do
    local name = select(i, ...)
    assert(type(name) == 'string')
    table.insert(subs, (assert(topics[name], 'invalid topic ' .. tostring(name))))
  end
  multisub(subs, func)
end

local addonName, G = ...

function G.LocalToServer(t)
  return t ~= 0 and GetServerTime() + t - GetTime() or 0
end

function G.ServerToLocal(t)
  return t ~= 0 and GetTime() + t - GetServerTime() or 0
end

function G.Eventer(handlers)
  local frame = CreateFrame('Frame')
  for ev in pairs(handlers) do
    frame:RegisterEvent(ev)
  end
  frame:SetScript('OnEvent', function(_, ev, ...)
    handlers[ev](...)
  end)
end

function G.NonCombatEventer(handlers)
  local newHandlers = {}
  local queue = {}
  for ev, handler in pairs(handlers) do
    newHandlers[ev] = function(...)
      if InCombatLockdown() then
        local args = { ... }
        table.insert(queue, function()
          handler(unpack(args))
        end)
      else
        handler(...)
      end
    end
  end
  local regen = 'PLAYER_REGEN_ENABLED'
  newHandlers[regen] = function()
    for _, callback in ipairs(queue) do
      callback()
    end
    queue = {}
    if handlers[regen] then
      handlers[regen]()
    end
  end
  G.Eventer(newHandlers)
end

do
  local parent = CreateFrame('Frame')
  parent:Hide()
  function G.ReparentFrame(frame)
    frame:SetParent(parent)
  end
end

function G.Updater(period, fn)
  local updateTimer = -1
  CreateFrame('Frame'):SetScript('OnUpdate', function(_, elapsed)
    updateTimer = updateTimer - elapsed
    if updateTimer <= 0 then
      updateTimer = period
      fn()
    end
  end)
end

function G.PreClickButton(name, default, func)
  local button = CreateFrame('Button', addonName .. name, nil, 'SecureActionButtonTemplate')
  button:SetAttribute('type', 'macro')
  button:SetAttribute('macrotext', default)
  local lastemote = nil
  local lastemotetime = 0
  local function macrotext()
    local macro, emote = func()
    if macro then
      return macro
    elseif emote then
      local now = GetTime()
      if emote ~= lastemote or now - lastemotetime > 20 then
        lastemote = emote
        lastemotetime = now
        return '/' .. emote .. ' [@none]'
      end
    else
      return default
    end
  end
  button:HookScript('PreClick', function(self)
    if not InCombatLockdown() then
      self:SetAttribute('macrotext', macrotext() or '')
    end
  end)
  button:HookScript('OnClick', function(self)
    if not InCombatLockdown() then
      self:SetAttribute('macrotext', default)
    end
  end)
  return button
end

do
  local partyChangeFuncs = {}

  local function propagateChange()
    local myname = UnitName('player')
    local members = { myname }
    for i = 1, GetNumGroupMembers() do
      local name = UnitName('party' .. i)
      table.insert(members, name)
    end
    table.sort(members)
    for _, func in ipairs(partyChangeFuncs) do
      func(members)
    end
  end

  G.NonCombatEventer({
    PLAYER_ENTERING_WORLD = propagateChange,
    GROUP_ROSTER_UPDATE = propagateChange,
  })

  function G.OnPartyChangeSafely(func)
    table.insert(partyChangeFuncs, func)
  end
end

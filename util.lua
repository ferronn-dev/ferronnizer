local _, G = ...

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

do
  local parent = CreateFrame('Frame')
  parent:Hide()
  function G.ReparentFrame(frame)
    frame:SetParent(parent)
  end
end

function G.PreClickButton(name, default, func)
  local button = CreateFrame('Button', name, nil, 'SecureActionButtonTemplate')
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
        return '/'..emote..' [@none]'
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
end

do
  local partyChangeFuncs = {}
  local updateRequested = false

  local function propagateChange()
    local myname = UnitName('player')
    local members = {myname}
    for i = 1, GetNumGroupMembers() do
      local name = UnitName('party'..i)
      table.insert(members, name)
    end
    table.sort(members)
    for _, func in ipairs(partyChangeFuncs) do
      func(members)
    end
  end

  local function onPartyChange()
    if InCombatLockdown() then
      updateRequested = true
    else
      propagateChange()
    end
  end

  local function afterCombat()
    if updateRequested then
      propagateChange()
      updateRequested = false
    end
  end

  G.Eventer({
    PLAYER_ENTERING_WORLD = onPartyChange,
    GROUP_ROSTER_UPDATE = onPartyChange,
    PLAYER_REGEN_ENABLED = afterCombat,
  })

  function G.OnPartyChangeSafely(func)
    table.insert(partyChangeFuncs, func)
  end
end

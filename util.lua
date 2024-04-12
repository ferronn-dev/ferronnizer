local addonName, G = ...

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
  button:HookScript('PreClick', function(self)
    if not InCombatLockdown() then
      self:SetAttribute('macrotext', func() or '')
    end
  end)
  button:HookScript('OnClick', function(self)
    if not InCombatLockdown() then
      self:SetAttribute('macrotext', default)
    end
  end)
  return button
end

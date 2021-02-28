local _, G = ...
local bindings = {
  ['`'] = 'TOGGLEAUTORUN',
  ['CTRL-`'] = 'ATTC_TOGGLEMINILIST',
  ['CTRL-TAB'] = 'TOGGLEMINIMAP',
  ['ALT-B'] = 'OPENALLBAGS',
  ['ALT-C'] = 'TOGGLECHARACTER0',
  ['ALT-L'] = 'TOGGLEQUESTLOG',
  ['ALT-N'] = 'TOGGLETALENTS',
  ['ALT-M'] = 'TOGGLEWORLDMAP',
  ['ALT-P'] = 'TOGGLESPELLBOOK',
  ['MOUSEWHEELUP'] = 'INTERACTMOUSEOVER',
  ['MOUSEWHEELDOWN'] = 'INTERACTMOUSEOVER',
  ['SHIFT-MOUSEWHEELUP'] = 'CAMERAZOOMIN',
  ['SHIFT-MOUSEWHEELDOWN'] = 'CAMERAZOOMOUT',
}
local actionbar = {
  '1', '2', '3', '4', 'R', 'A',
  'D', 'F', 'Z', 'X', 'C', 'V',
}
local bartender = {
  'CTRL-Q', 'CTRL-W', 'CTRL-E', 'CTRL-R', 'CTRL-T', 'CTRL-Y',
  'CTRL-1', 'CTRL-2', 'CTRL-3', 'CTRL-4', 'CTRL-5', 'CTRL-6',
  'CTRL-A', 'CTRL-S', 'CTRL-D', 'CTRL-F', 'CTRL-G', 'CTRL-H',
  'CTRL-Z', 'CTRL-X', 'CTRL-C', 'CTRL-V', 'CTRL-B', 'CTRL-N',
  'SHIFT-A', 'SHIFT-S', 'SHIFT-D', 'SHIFT-F', 'SHIFT-G', 'SHIFT-H',
  'SHIFT-Z', 'SHIFT-X', 'SHIFT-C', 'SHIFT-V', 'SHIFT-B', 'SHIFT-N',
}
G.Eventer({
  PLAYER_LOGIN = function()
    for k, v in pairs(bindings) do
      SetBinding(k, v)
    end
    for _, c in ipairs({'5', '6', '7', '8', '9', '0', '-', '='}) do
      SetBinding(c, nil)
    end
    for i, b in ipairs(actionbar) do
      SetBinding(b, 'ACTIONBUTTON' .. i)
    end
    for i, b in ipairs(bartender) do
      SetBinding(b, 'CLICK BT4Button' .. (i + #actionbar) .. ':LeftButton')
    end
  end,
})

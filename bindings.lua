local addonName, G = ...
local isMainline = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local bindings = {
  ['`'] = 'TOGGLEAUTORUN',
  ['CTRL-`'] = isMainline and 'ALLTHETHINGS_TOGGLEMINILIST' or 'ATTC_TOGGLEMINILIST',
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
  ['ALT-1'] = 'RAIDTARGET8',
  ['ALT-2'] = 'RAIDTARGET7',
  ['ALT-3'] = 'RAIDTARGET6',
  ['ALT-4'] = 'RAIDTARGET5',
  ['ALT-Q'] = 'RAIDTARGET4',
  ['ALT-W'] = 'RAIDTARGET3',
  ['ALT-E'] = 'RAIDTARGET2',
  ['ALT-R'] = 'RAIDTARGET1',
  ['ALT-`'] = 'RAIDTARGETNONE',
}
local actionbars = {
  '1', '2', '3', '4', 'R', 'A',
  'D', 'F', 'Z', 'X', 'C', 'V',
  'CTRL-Q', 'CTRL-W', 'CTRL-E', 'CTRL-R', 'CTRL-T', 'CTRL-Y',
  'CTRL-1', 'CTRL-2', 'CTRL-3', 'CTRL-4', 'CTRL-5', 'CTRL-6',
  'CTRL-A', 'CTRL-S', 'CTRL-D', 'CTRL-F', 'CTRL-G', 'CTRL-H',
  'CTRL-Z', 'CTRL-X', 'CTRL-C', 'CTRL-V', 'CTRL-B', 'CTRL-N',
  'SHIFT-A', 'SHIFT-S', 'SHIFT-D', 'SHIFT-F', 'SHIFT-G', 'SHIFT-H',
  'SHIFT-Z', 'SHIFT-X', 'SHIFT-C', 'SHIFT-V', 'SHIFT-B', 'SHIFT-N',
}
local switchers = {
  ['ALT-CTRL-A'] = 'Aura',
  ['ALT-CTRL-W'] = 'Noncombat',
  ['ALT-CTRL-E'] = 'Emote',
  ['CTRL-SHIFT-1'] = 'Profession',
  ['CTRL-SHIFT-2'] = 'Pet',
  ['F1'] = 'Default',
  ['F2'] = 'Fraction2',
  ['F3'] = 'Fraction3',
  ['F4'] = 'Fraction4',
  ['F5'] = 'Fraction5',
}

G.Eventer({
  PLAYER_LOGIN = function()
    for k, v in pairs(bindings) do
      SetBinding(k, v)
    end
    for _, c in ipairs({'5', '6', '7', '8', '9', '0', '-', '='}) do
      SetBinding(c, nil)
    end
    for i, b in ipairs(actionbars) do
      SetBindingClick(b, addonName .. 'ActionButton' .. i)
    end
    for k, v in pairs(switchers) do
      SetBindingClick(k, addonName .. 'ActionButton' .. v .. 'Switcher')
    end
  end,
})

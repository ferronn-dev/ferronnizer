local addonName, G = ...
local isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local bindings = {
  ['`'] = 'TOGGLEAUTORUN',
  ['CTRL-`'] = isClassic and 'ATTC_TOGGLEMINILIST' or 'ALLTHETHINGS_TOGGLEMINILIST',
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
  ['CTRL-SHIFT-D'] = 'CLICK ToggleActionDragButton:LeftButton',
  ['CTRL-SHIFT-V'] = 'CLICK PartyBuffButton:LeftButton',
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
local multi = {
  ['A'] = '/cast Alchemy',
  ['C'] = '/cast Cooking',
  ['D'] = '/cast Disenchant',
  ['E'] = '/cast Enchanting',
  ['F'] = '/cast First Aid',
  ['R'] = '/cast Tailoring',
  ['S'] = '/cast Smelting',
  ['W'] = '/cast Leatherworking',
  ['X'] = '/cast Blacksmithing',
}

local function setupMultiBindings()
  local newButton = function(name)
    return CreateFrame('Button', addonName .. 'MultiBinding' .. name, nil, 'SecureActionButtonTemplate')
  end
  local root = newButton('Root')
  local buttons = {}
  for k, v in pairs(multi) do
    local button = newButton('Child-' .. k)
    button:SetAttribute('type', 'macro')
    button:SetAttribute('macrotext', v)
    buttons[k] = button
  end
  local header = CreateFrame('Frame', nil, nil, 'SecureHandlerStateTemplate')
  header:WrapScript(root, 'OnClick', 'owner:Run(start)', '')
  header:SetFrameRef('root', root)
  header:Execute([[
    root = owner:GetFrameRef('root')
    buttons = newtable()
    start = [=[
      owner:ClearBindings()
      for k, v in pairs(buttons) do
        owner:SetBindingClick(true, k, v:GetName())
      end
    ]=]
    stop = [=[
      owner:ClearBindings()
      owner:SetBindingClick(true, 'CTRL-P', root:GetName())
    ]=]
    owner:Run(stop)
  ]])
  for k, v in pairs(buttons) do
    header:SetFrameRef('binding-' .. k, v)
    header:Execute(string.format([[buttons['%s'] = owner:GetFrameRef('binding-%s')]], k, k))
    header:WrapScript(v, 'OnClick', 'owner:Run(stop)', '')
  end
end

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
    setupMultiBindings()
  end,
})

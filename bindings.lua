local _, G = ...
local bindings = {
  ['`'] = 'TOGGLEAUTORUN',
  ['ALT-B'] = 'OPENALLBAGS',
  ['ALT-C'] = 'TOGGLECHARACTER0',
  ['ALT-L'] = 'TOGGLEQUESTLOG',
  ['ALT-N'] = 'TOGGLETALENTS',
  ['ALT-M'] = 'TOGGLEWORLDMAP',
  ['ALT-P'] = 'TOGGLESPELLBOOK',
}
G.Eventer({
  PLAYER_LOGIN = function()
    for k, v in pairs(bindings) do
      SetBinding(k, v)
    end
  end,
})

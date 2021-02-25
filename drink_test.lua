local T = require('testing')

T.RunTests({
  function(state)
    local button = state.frames['DrinkButton']
    button:Click()
    T.assertEquals('macro', button:GetAttribute('type'))
    T.assertEquals('', button:GetAttribute('macrotext'))
    T.assertEquals({{ macro = '/thirsty [@none]' }}, state.commands)
  end,
})

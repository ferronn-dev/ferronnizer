describe('drink button', function()
  it('defaults to thirsty emote', function()
    local button = wow.env.mooDrinkButton
    button:Click()
    assert.same('macro', button:GetAttribute('type'))
    assert.same('', button:GetAttribute('macrotext'))
    assert.same({{ macro = '/thirsty [@none]' }}, wow.state.commands)
  end)
  it('drinks', function()
    wow.state.inventory[3772] = 10
    wow.state.inventory[2288] = 5
    wow.env.mooDrinkButton:Click()
    assert.same({{ macro = '/use item:3772' }}, wow.state.commands)
  end)
end)

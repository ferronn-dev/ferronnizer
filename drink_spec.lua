describe('drink', function()
  it('defaults to thirsty emote', function()
    local button = wow.state.frames['DrinkButton']
    button:Click()
    assert.same('macro', button:GetAttribute('type'))
    assert.same('', button:GetAttribute('macrotext'))
    assert.same({{ macro = '/thirsty [@none]' }}, wow.state.commands)
  end)
end)

describe('ui', function()
  it('loads', function()
    local root = wow.env.FerronnizerRoot
    assert.Not.Nil(root)
    assert.Not.Nil(root.Clock)
    assert.Not.Nil(root.Hidden)
  end)
end)

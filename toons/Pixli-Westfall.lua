local addonName, G = ...
G.Characters = G.Characters or {}
G.Characters['Pixli-Westfall'] = {
  [1] = {
    spell = 'Frostbolt',
  },
  [2] = {
    spell = 'Fireball',
  },
  [3] = {
    spell = 'Fire Blast',
  },
  [4] = {
    spell = 'Arcane Missiles',
  },
  [5] = {
    spell = 'Polymorph',
  },
  [6] = {
    spell = 'Frost Nova',
  },
  [7] = {
    spell = 'Arcane Explosion',
  },
  [8] = {
    spell = '!Shoot',
  },
  [9] = {
    spell = 'Flamestrike',
  },
  [13] = {
    mouseover = true,
    spell = 'Remove Lesser Curse',
  },
  [15] = {
    mouseover = true,
    spell = 'Amplify Magic',
  },
  [16] = {
    mouseover = true,
    spell = 'Dampen Magic',
  },
  [17] = {
    spell = 'Detect Magic',
  },
  [18] = {
    spell = 'Escape Artist',
  },
  [34] = {
    macro = '/click ' .. addonName .. 'BuffButton',
  },
  [35] = {
    spell = 'Slow Fall',
  },
  [45] = {
    eat = true,
  },
  [46] = {
    drink = true,
  },
}

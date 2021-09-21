local _, G = ...
G.AddClassActionSpec('TBC', 9, {
  [1] = {
    spell = 'Shadow Bolt',
  },
  [2] = {
    spell = 'Immolate',
  },
  [3] = {
    spell = 'Corruption',
  },
  [4] = {
    spell = 'Curse of Weakness',
  },
  [5] = {
    spell = 'Life Tap',
  },
  [6] = {
    spell = 'Curse of Agony',
  },
  [7] = {
    spell = 'Fear',
  },
  [8] = {
    spell = '!Shoot',
  },
  [16] = {
    macro = '/petattack',
    texture = 'interface/icons/ability_racial_bloodrage',
    tooltip = 'Pet Attack',
  },
  [17] = {
    macro = '/petpassive',
    texture = 'interface/icons/ability_seal',
    tooltip = 'Pet Passive',
  },
  [33] = {
    page = {
      [1] = {
        spell = 'Summon Imp',
      },
    },
    texture = 136172,
  },
  [34] = {
    buff = true,
  },
  [35] = {
    racial = true,
  },
  [36] = {
    racial2 = true,
  },
  [43] = {
    mount = true,
  },
  [44] = {
    bandage = true,
  },
  [45] = {
    eat = true,
  },
  [46] = {
    drink = true,
  },
})

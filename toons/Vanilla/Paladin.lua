local _, G = ...
local flashOfLight = {
  ranks = { 1.0, 0.0 },
  spells = { 'Flash of Light' },
}
G.AddClassActionSpec('Vanilla', 2, {
  [1] = {
    oneof = {
      'Seal of Righteousness',
      'Seal of the Crusader',
      'Seal of Wisdom',
      'Seal of Light',
      'Seal of Justice',
    },
  },
  [2] = {
    macro = '/cast Judgement\n/click PallyPowerRF RightButton',
    ui = { spell = 'Judgement' },
  },
  [3] = {
    spell = 'Holy Shock',
  },
  [4] = {
    spell = 'Divine Favor',
  },
  [5] = {
    spell = 'Hammer of Justice',
  },
  [6] = {
    spell = 'Consecration',
  },
  [7] = {
    mouseover = true,
    spells = { 'Cleanse', 'Purify' },
  },
  [8] = {
    oneof = {
      'Blessing of Freedom',
      'Blessing of Kings',
      'Blessing of Light',
      'Blessing of Might',
      'Blessing of Protection',
      'Blessing of Sacrifice',
      'Blessing of Salvation',
      'Blessing of Wisdom',
    },
  },
  [9] = {
    spell = 'Exorcism',
  },
  [10] = {
    spell = 'Hammer of Wrath',
  },
  [11] = {
    spell = 'Holy Wrath',
  },
  [12] = {
    spell = 'Turn Undead',
  },
  [13] = {
    mouseover = true,
    spell = 'Holy Light',
  },
  [14] = {
    healset = flashOfLight,
    rank = 2,
  },
  [15] = {
    healset = flashOfLight,
    rank = 1,
  },
  [16] = {
    stopcasting = true,
  },
  [19] = {
    invslot = 13,
  },
  [20] = {
    invslot = 14,
  },
  [21] = {
    spell = 'Redemption',
  },
  [25] = {
    oneof = {
      [25] = 'Devotion Aura',
      [26] = 'Retribution Aura',
      [27] = 'Concentration Aura',
      [28] = 'Fire Resistance Aura',
      [29] = 'Frost Resistance Aura',
      [30] = 'Shadow Resistance Aura',
    },
  },
  [30] = {
    spells = { 'Divine Shield', 'Divine Protection' },
    stopcasting = true,
  },
  [31] = {
    mouseover = true,
    spell = 'Blessing of Freedom',
  },
  [32] = {
    mouseover = true,
    spell = 'Blessing of Protection',
    stopcasting = true,
  },
  [33] = {
    mouseover = true,
    spell = 'Blessing of Sacrifice',
  },
  [34] = {
    buff = true,
    reagent = 21177,
  },
  [35] = {
    racial = true,
  },
  [36] = {
    racial2 = true,
  },
  [37] = {
    spell = 'Fishing',
  },
  [41] = {
    mouseover = true,
    spell = 'Lay on Hands',
    stopcasting = true,
  },
  [42] = {
    spell = 'Divine Intervention',
    stopcasting = true,
  },
  [43] = {
    mount = true,
  },
  [45] = {
    eat = true,
  },
  [46] = {
    drink = true,
  },
})

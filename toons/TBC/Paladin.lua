local _, G = ...
G.AddClassActionSpec('TBC', 2, {
  [1] = {
    oneof = {
      [1] = 'Seal of Righteousness',
      [2] = 'Seal of the Crusader',
    },
  },
  [2] = {
    macro = '/cast Judgement\n/cast PallyPowerRF RightButton',
    ui = { spell = 'Judgement' },
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
    spells = {'Cleanse', 'Purify'},
  },
  [8] = {
    page = {
      [1] = {
        mouseover = true,
        spell = 'Blessing of Might',
      },
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
    },
  },
  [26] = {
    macro = '/click PallyPowerAuto RightButton',
    texture = 'interface/icons/trade_engineering',
    tooltip = 'PallyPower',
  },
  [30] = {
    spells = {'Divine Shield', 'Divine Protection'},
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

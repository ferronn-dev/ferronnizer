local _, G = ...
local slowHeals = {
  ranks = { 1.0, 0.7, 0.4 },
  spells = { 'Greater Heal', 'Heal', 'Lesser Heal' },
}
local fastHeals = {
  ranks = { 1.0, 0.3, 0 },
  spells = { 'Flash Heal' },
}
G.AddClassActionSpec('Vanilla', 5, {
  [1] = {
    healset = slowHeals,
    rank = 3,
  },
  [2] = {
    healset = slowHeals,
    rank = 2,
  },
  [3] = {
    healset = slowHeals,
    rank = 1,
  },
  [4] = {
    stopcasting = true,
  },
  [5] = {
    mouseover = true,
    spell = 'Renew',
  },
  [6] = {
    spell = 'Holy Nova',
  },
  [7] = {
    mouseover = true,
    spell = 'Power Word: Shield',
  },
  [8] = {
    spell = '!Shoot',
  },
  [9] = {
    spell = 'Smite',
  },
  [10] = {
    spell = 'Shadow Word: Pain',
  },
  [11] = {
    spell = 'Mind Blast',
  },
  [12] = {
    spell = 'Psychic Scream',
  },
  [13] = {
    healset = fastHeals,
    rank = 3,
  },
  [14] = {
    healset = fastHeals,
    rank = 2,
  },
  [15] = {
    healset = fastHeals,
    rank = 1,
  },
  [16] = {
    stopcasting = true,
  },
  [17] = {
    spell = 'Inner Focus',
  },
  [18] = {
    spell = 'Prayer of Healing',
  },
  [19] = {
    invslot = 13,
  },
  [20] = {
    invslot = 14,
  },
  [21] = {
    mouseover = true,
    spell = 'Power Infusion',
  },
  [22] = {
    spell = 'Mind Vision',
  },
  [23] = {
    spell = 'Mana Burn',
  },
  [24] = {
    spell = 'Mind Soothe',
  },
  [25] = {
    mouseover = true,
    spell = 'Dispel Magic',
  },
  [26] = {
    mouseover = true,
    spell = 'Abolish Disease',
  },
  [27] = {
    spell = 'Fade',
  },
  [28] = {
    spell = 'Desperate Prayer',
  },
  [29] = {
    spell = 'Mind Control',
  },
  [30] = {
    spell = 'Shackle Undead',
  },
  [31] = {
    racial = true,
  },
  [32] = {
    spell = 'Holy Fire',
  },
  [33] = {
    spell = 'Resurrection',
  },
  [34] = {
    buff = true,
    reagent = 17029,
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

local _, G = ...
G.Characters = G.Characters or {}
G.Characters['Shydove-Westfall'] = {
  [1] = {
    actionText = 'GH5',
    mouseover = true,
    rank = 5,
    spell = 'Greater Heal',
  },
  [2] = {
    actionText = 'GH1',
    mouseover = true,
    rank = 1,
    spell = 'Greater Heal',
  },
  [3] = {
    actionText = 'H2',
    mouseover = true,
    rank = 2,
    spell = 'Heal',
  },
  [4] = {
    stopcasting = true,
  },
  [5] = {
    mouseover = true,
    spell = 'Renew',
  },
  [6] = {
    mouseover = WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC,
    spell = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and 'Holy Nova' or 'Circle of Healing',
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
    actionText = 'FH8',
    mouseover = true,
    rank = 8,
    spell = 'Flash Heal',
  },
  [14] = {
    actionText = 'FH3',
    mouseover = true,
    rank = 3,
    spell = 'Flash Heal',
  },
  [15] = {
    actionText = 'FH1',
    mouseover = true,
    rank = 1,
    spell = 'Flash Heal',
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
    spell = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and 'Power Infusion' or 'Fear Ward',
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
    spell = 'Perception',
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
}

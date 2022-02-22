local _, G = ...
G.AddClassActionSpec('TBC', 5, {
  [1] = {
    actionText = 'GH7',
    mouseover = true,
    rank = 7,
    spell = 'Greater Heal',
  },
  [2] = {
    actionText = 'GH1',
    mouseover = true,
    rank = 1,
    spell = 'Greater Heal',
  },
  [3] = {
    mouseover = true,
    spell = 'Prayer of Mending',
  },
  [4] = {
    stopcasting = true,
  },
  [5] = {
    mouseover = true,
    spell = 'Renew',
  },
  [6] = {
    mouseover = true,
    spell = 'Circle of Healing',
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
    actionText = 'FH9',
    mouseover = true,
    rank = 9,
    spell = 'Flash Heal',
  },
  [14] = {
    actionText = 'FH3',
    mouseover = true,
    rank = 3,
    spell = 'Flash Heal',
  },
  [15] = {
    mouseover = true,
    spell = 'Binding Heal',
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
    spell = 'Fear Ward',
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
    options = '[@mouseover,nodead][]',
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
    spell = ({
      ['Blood Elf'] = 'Touch of Weakness',
      Draenei = 'Symbol of Hope',
      Dwarf = 'Desperate Prayer',
      Human = 'Desperate Prayer',
      ['Night Elf'] = 'Elune\'s Grace',
      Troll = 'Hex of Weakness',
      Undead = 'Touch of Weakness',
    })[UnitRace(
      'player'
    )],
  },
  [29] = {
    spell = 'Mind Control',
  },
  [30] = {
    spell = 'Shackle Undead',
  },
  [31] = {
    spell = 'Shadowfiend',
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
  [35] = {
    racial = true,
  },
  [36] = {
    racial2 = true,
  },
  [37] = {
    spell = 'Shadow Word: Death',
  },
  [38] = {
    spell = 'Mass Dispel',
  },
  [39] = (function()
    local spells = {
      ['Blood Elf'] = 'Consume Magic',
      Human = 'Feedback',
      ['Night Elf'] = 'Starshards',
      Troll = 'Shadowguard',
      Undead = 'Devouring Plague',
    }
    local spell = spells[UnitRace('player')]
    return spell and { spell = spell } or nil
  end)(),
  [40] = {
    spell = 'Levitate',
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

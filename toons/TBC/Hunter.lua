local _, G = ...
G.AddClassActionSpec('TBC', 3, {
  [1] = {
    spell = '!Auto Shot',
  },
  [2] = {
    spells = { 'Steady Shot', 'Arcane Shot' },
  },
  [3] = {
    spell = 'Multi-Shot',
  },
  [5] = {
    spell = 'Hunter\'s Mark',
  },
  [6] = {
    spell = 'Bestial Wrath',
  },
  [7] = {
    oneof = {
      'Serpent Sting',
      'Scorpid Sting',
      'Viper Sting',
    },
  },
  [8] = {
    spell = 'Raptor Strike',
  },
  [9] = {
    page = {
      [9] = { spell = 'Explosive Trap' },
      [10] = { spell = 'Freezing Trap' },
      [11] = { spell = 'Frost Trap' },
      [12] = { spell = 'Immolation Trap' },
    },
    texture = 'interface/icons/ability_ensnare',
  },
  [10] = {
    spell = 'Volley',
  },
  [11] = {
    spell = 'Mongoose Bite',
  },
  [12] = {
    spell = 'Wing Clip',
  },
  [13] = {
    spell = 'Distracting Shot',
  },
  [14] = {
    spell = 'Concussive Shot',
  },
  [15] = {
    oneof = {
      'Aspect of the Hawk',
      'Aspect of the Cheetah',
      'Aspect of the Pack',
      'Aspect of the Monkey',
      'Aspect of the Wild',
      'Aspect of the Beast',
      'Aspect of the Viper',
    },
  },
  [16] = {
    petaction = 1,
  },
  [17] = {
    petaction = 2,
  },
  [18] = {
    petaction = 3,
  },
  [19] = {
    invslot = 13,
  },
  [20] = {
    invslot = 14,
  },
  [22] = {
    spell = 'Flare',
  },
  [25] = {
    spell = 'Disengage',
  },
  [26] = {
    spell = 'Feign Death',
  },
  [27] = {
    spell = 'Mend Pet',
  },
  [28] = {
    page = {
      { spell = 'Beast Lore' },
      { spell = 'Call Pet' },
      { spell = 'Dismiss Pet' },
      { spell = 'Eagle Eye' },
      { spell = 'Eyes of the Beast' },
      { spell = 'Feed Pet' },
      { spell = 'Revive Pet' },
      { spell = 'Tame Beast' },
      { spell = 'Scare Beast' },
      { spell = 'Beast Training' },
    },
    texture = 132270,
  },
  [29] = {
    spell = 'Aimed Shot',
  },
  [31] = {
    spell = 'Arcane Shot',
  },
  [32] = {
    spell = 'Rapid Fire',
  },
  [33] = {
    oneof = {
      'Track Beasts',
      'Track Demons',
      'Track Dragonkin',
      'Track Elementals',
      'Track Giants',
      'Track Hidden',
      'Track Humanoids',
      'Track Undead',
    },
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
  [37] = {
    spell = 'Intimidation',
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

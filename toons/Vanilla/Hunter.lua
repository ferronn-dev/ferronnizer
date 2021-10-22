local _, G = ...
G.AddClassActionSpec('Vanilla', 3, {
  [1] = {
    spell = '!Auto Shot',
  },
  [2] = {
    spells = {'Aimed Shot', 'Arcane Shot'},
  },
  [3] = {
    spell = 'Multi-Shot',
  },
  [4] = {
    spell = 'Serpent Sting',
  },
  [5] = {
    spell = 'Hunter\'s Mark',
  },
  [6] = {
    spell = 'Bestial Wrath',
  },
  [7] = {
    spell = 'Concussive Shot',
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
    spell = 'Scorpid Sting',
  },
  [15] = {
    spell = 'Viper Sting',
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
  [21] = {
    oneof = {
      [19] = 'Aspect of the Hawk',
      [20] = 'Aspect of the Cheetah',
      [21] = 'Aspect of the Pack',
      [22] = 'Aspect of the Monkey',
      [23] = 'Aspect of the Wild',
      [24] = 'Aspect of the Beast',
    },
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

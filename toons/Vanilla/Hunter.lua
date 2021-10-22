local _, G = ...
G.AddClassActionSpec('Vanilla', 3, {
  [1] = {
    spell = '!Auto Shot',
  },
  [8] = {
    spell = 'Raptor Strike',
  },
  [19] = {
    oneof = {
      [19] = 'Aspect of the Hawk',
      [20] = 'Aspect of the Cheetah',
      [21] = 'Aspect of the Pack',
      [22] = 'Aspect of the Monkey',
      [23] = 'Aspect of the Wild',
      [24] = 'Aspect of the Beast',
    },
  },
  [20] = {
    page = {
      { spell = 'Beast Lore' },
      { spell = 'Call Pet' },
      { spell = 'Dismiss Pet' },
      { spell = 'Eagle Eye' },
      { spell = 'Eyes of the Beast' },
      { spell = 'Feed Pet' },
      { spell = 'Mend Pet' },
      { spell = 'Revive Pet' },
      { spell = 'Tame Beast' },
      { spell = 'Scare Beast' },
      { spell = 'Beast Training' },
    },
    texture = 132270,
  },
  [21] = {
    page = {
      { spell = 'Arcane Shot' },
      { spell = 'Concussive Shot' },
      { spell = 'Distracting Shot' },
      { spell = 'Flare' },
      { spell = 'Hunter\'s Mark' },
      { spell = 'Multi-Shot' },
      { spell = 'Rapid Fire' },
      { spell = 'Scorpid Sting' },
      { spell = 'Serpent Sting' },
      { spell = 'Viper Sting' },
      { spell = 'Volley' },
    },
    texture = 132222,
  },
  [22] = {
    page = {
      { spell = 'Disengage' },
      { spell = 'Explosive Trap' },
      { spell = 'Feign Death' },
      { spell = 'Freezing Trap' },
      { spell = 'Frost Trap' },
      { spell = 'Immolation Trap' },
      { spell = 'Mongoose Bite' },
      { spell = 'Wing Clip' },
    },
    texture = 132215,
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

local allsets = {
  ['Shydove-Westfall'] = {
    Healing = {},
    Intellect = {
      [1] = 16813, -- Circlet of Prophecy
      [2] = 13141, -- Tooth of Gnarr
      [3] = 16816, -- Mantle of Prophecy
      [5] = 16815, -- Robes of Prophecy
      [6] = 16817, -- Girdle of Prophecy
      [7] = 16814, -- Pants of Prophecy
      [8] = 16811, -- Boots of Prophecy
      [9] = 16819, -- Vambraces of Prophecy
      [10] = 16812, -- Gloves of Prophecy
      [11] = 19920, -- Primalist's Band
      [12] = 17110, -- Seal of the Archmagus
      [13] = 19950, -- Zandalarian Hero Charm
      [14] = 13968, -- Eye of the Beast
      [15] = 18510, -- Hide of the Wild
      [16] = 18608, -- Benediction
    },
  },
}

local sets = allsets[UnitName('player') .. '-' .. GetRealmName()]
if sets then
  print('progress')
end

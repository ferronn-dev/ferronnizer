-- HealthPotionDB
SELECT
  CAST(itemsparse.id AS INT64) AS itemid,
  CAST(itemsparse.requiredlevel AS INT64) AS level,
  IF(
    CAST(itemsparse.flags_0_ AS INT64) & 2 > 0,
    CAST(iz.spellid AS INT64),
    NULL
  ) AS spellid
FROM itemsparse
INNER JOIN itemeffect ON itemsparse.id = itemeffect.parentitemid
INNER JOIN spelleffect AS ez ON itemeffect.spellid = ez.spellid
LEFT OUTER JOIN spelleffect AS iz ON itemsparse.id = iz.effectitemtype
WHERE
  itemeffect.spellid != "41620"  -- Bottled Nethergon Vapor
  AND itemeffect.spellcategoryid IN ("4", "1153")
  AND ez.effect = "10"
ORDER BY
  CAST(itemsparse.itemlevel AS INT64) DESC, level DESC, itemid ASC, spellid ASC;

-- ManaPotionDB
SELECT
  CAST(itemsparse.id AS INT64) AS itemid,
  CAST(itemsparse.requiredlevel AS INT64) AS level,
  IF(
    CAST(itemsparse.flags_0_ AS INT64) & 2 > 0,
    CAST(iz.spellid AS INT64),
    NULL
  ) AS spellid
FROM itemsparse
INNER JOIN itemeffect ON itemsparse.id = itemeffect.parentitemid
INNER JOIN spelleffect AS ez ON itemeffect.spellid = ez.spellid
LEFT OUTER JOIN spelleffect AS iz ON itemsparse.id = iz.effectitemtype
WHERE
  itemeffect.spellid != "41618"  -- Bottled Nethergon Vapor
  AND itemeffect.spellcategoryid IN ("4", "1153")
  AND ez.effect = "30"
ORDER BY
  CAST(itemsparse.itemlevel AS INT64) DESC, level DESC, itemid ASC, spellid ASC;

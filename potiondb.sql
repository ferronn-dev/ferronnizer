-- HealthPotionDB
SELECT
  CAST(s.id AS INT64),
  CAST(s.requiredlevel AS INT64),
  IF(CAST(s.flags_0_ AS INT64) & 0x2 > 0, CAST(iz.spellid AS INT64), NULL)
FROM itemsparse s
JOIN itemeffect e ON s.id = e.parentitemid
JOIN spelleffect ez ON e.spellid = ez.spellid
LEFT OUTER JOIN spelleffect iz ON s.id = iz.effectitemtype
WHERE e.spellid <> "41620"  -- Bottled Nethergon Vapor
  AND e.spellcategoryid IN ("4", "1153")
  AND ez.effect = "10"
ORDER BY CAST(s.itemlevel AS INT64) DESC;

-- ManaPotionDB
SELECT
  CAST(s.id AS INT64),
  CAST(s.requiredlevel AS INT64),
  IF(CAST(s.flags_0_ AS INT64) & 0x2 > 0, CAST(iz.spellid AS INT64), NULL)
FROM itemsparse s
JOIN itemeffect e ON s.id = e.parentitemid
JOIN spelleffect ez ON e.spellid = ez.spellid
LEFT OUTER JOIN spelleffect iz ON s.id = iz.effectitemtype
WHERE e.spellid <> "41618"  -- Bottled Nethergon Vapor
  AND e.spellcategoryid IN ("4", "1153")
  AND ez.effect = "30"
ORDER BY CAST(s.itemlevel AS INT64) DESC;

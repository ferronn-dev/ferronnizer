-- HealthPotionDB
SELECT CAST(s.id AS INT64), CAST(s.requiredlevel AS INT64)
FROM itemsparse s, itemeffect e, spelleffect z
WHERE s.id = e.parentitemid
  AND e.spellid <> "41620"  -- Bottled Nethergon Vapor
  AND e.spellcategoryid IN ("4", "1153")
  AND z.spellid = e.spellid
  AND z.effect = "10"
ORDER BY CAST(s.itemlevel AS INT64) DESC;

-- ManaPotionDB
SELECT CAST(s.id AS INT64), CAST(s.requiredlevel AS INT64)
FROM itemsparse s, itemeffect e, spelleffect z
WHERE s.id = e.parentitemid
  AND e.spellid <> "41618"  -- Bottled Nethergon Energy
  AND e.spellcategoryid IN ("4", "1153")
  AND z.spellid = e.spellid
  AND z.effect = "30"
ORDER BY CAST(s.itemlevel AS INT64) DESC;

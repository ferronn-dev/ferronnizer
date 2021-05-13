-- HealthPotionDB
SELECT CAST(s.id AS INT64)
FROM itemsparse s, itemeffect e, spelleffect z
WHERE s.id = e.parentitemid
  AND e.spellcategoryid = "4"
  AND z.spellid = e.spellid
  AND z.effect = "10"
ORDER BY CAST(s.itemlevel AS INT64) DESC;

-- ManaPotionDB
SELECT CAST(s.id AS INT64)
FROM itemsparse s, itemeffect e, spelleffect z
WHERE s.id = e.parentitemid
  AND e.spellcategoryid = "4"
  AND z.spellid = e.spellid
  AND z.effect = "30"
ORDER BY CAST(s.itemlevel AS INT64) DESC;

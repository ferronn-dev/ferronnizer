SELECT CAST(id AS INT64)
FROM itemsparse s
WHERE display_lang LIKE '%Healing Potion'
ORDER BY CAST(itemlevel AS INT64) DESC;

SELECT CAST(s.id AS INT64)
FROM itemsparse s, itemeffect e, spelleffect z
WHERE s.id = e.parentitemid
  AND e.spellcategoryid = "4"
  AND z.spellid = e.spellid
  AND z.effect = "30"
ORDER BY CAST(s.itemlevel AS INT64) DESC;

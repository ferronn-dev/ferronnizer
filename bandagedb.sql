SELECT CAST(s.id AS INT64), CAST(s.requiredskillrank AS INT64)
FROM itemsparse s, itemeffect e, spelleffect z
WHERE s.id = e.parentitemid
  AND e.spellcategoryid = '150'
  AND e.spellid = z.spellid
  AND z.effect = '6'
ORDER BY CAST(s.requiredskillrank AS INT64) DESC;

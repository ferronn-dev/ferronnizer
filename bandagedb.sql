SELECT CAST(s.id AS INT64), CAST(s.requiredskillrank AS INT64)
FROM itemsparse s, itemeffect e
WHERE s.id = e.parentitemid
  AND s.display_lang LIKE '%Bandage%'
  AND e.spellcategoryid = '150'
ORDER BY CAST(s.requiredskillrank AS INT64) DESC;

SELECT CAST(s.id AS INT64), CAST(e.spellid AS INT64)
FROM itemsparse s, itemeffect e
WHERE e.parentitemid = s.id AND e.spellcategoryid = "59"
ORDER BY CAST(s.itemlevel AS INT64) DESC;

SELECT CAST(s.id AS INT64), CAST(e.spellid AS INT64)
FROM itemsparse s, itemeffect e
WHERE display_lang LIKE 'Conjured%Water'
AND s.id = e.parentitemid
ORDER BY CAST(itemlevel AS INT64) DESC;

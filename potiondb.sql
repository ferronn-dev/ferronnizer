SELECT CAST(id AS INT64)
FROM itemsparse s
WHERE display_lang LIKE '%Healing Potion'
ORDER BY CAST(itemlevel AS INT64) DESC;

SELECT CAST(id AS INT64)
FROM itemsparse s
WHERE display_lang LIKE '%Mana Potion'
ORDER BY CAST(itemlevel AS INT64) DESC;

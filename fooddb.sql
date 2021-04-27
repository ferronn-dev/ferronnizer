SELECT
  CAST(s.id AS INT64),
  CAST(e.spellid AS INT64),
  CAST(z.spellid AS INT64)
FROM
  itemsparse s
JOIN
  itemeffect e
ON
  e.parentitemid = s.id
LEFT OUTER JOIN
  spelleffect z
ON
  s.id = z.effectitemtype
WHERE
  e.spellcategoryid = "11" AND
  s.display_lang LIKE "Conjured%"
ORDER BY
  CAST(s.itemlevel AS INT64) DESC;

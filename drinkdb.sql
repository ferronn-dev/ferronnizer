SELECT
  CAST(s.id AS INT64),
  CAST(s.requiredlevel AS INT64),
  IF(CAST(s.flags_0_ AS INT64) & 0x2 > 0, CAST(z.spellid AS INT64), NULL)
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
  e.spellcategoryid = "59"
ORDER BY
  CAST(s.itemlevel AS INT64) DESC, 2 DESC, 3 NULLS LAST, 1;

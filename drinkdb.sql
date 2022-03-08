SELECT
  CAST(itemsparse.id AS INT64) AS itemid,
  CAST(itemsparse.requiredlevel AS INT64) AS level,
  IF(
    CAST(itemsparse.flags_0_ AS INT64) & 2 > 0,
    CAST(spelleffect.spellid AS INT64),
    NULL
  ) AS spellid
FROM
  itemsparse
INNER JOIN
  itemeffect
  ON
    itemeffect.parentitemid = itemsparse.id
LEFT OUTER JOIN
  spelleffect
  ON
    itemsparse.id = spelleffect.effectitemtype
WHERE
  itemeffect.spellcategoryid = "59"
ORDER BY
  CAST(itemsparse.itemlevel AS INT64) DESC,
  level DESC,
  spellid ASC NULLS LAST,
  itemid ASC;

SELECT
  CAST(e.parentitemid AS INT64)
FROM
  itemeffect e,
  spelleffect s
WHERE
  s.spellid = e.spellid
  AND e.spellcategoryid = "330"
  AND s.effectaura = "32"
ORDER BY
  s.effectbasepoints DESC,
  1

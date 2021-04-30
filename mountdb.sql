-- MountItemDB
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
  1;

-- MountSpellDB
SELECT
  CAST(s.spellid AS INT64)
FROM
  spelleffect s,
  skilllineability k
WHERE
  s.spellid = k.spell
  AND s.effectaura = "32"
ORDER BY
  s.effectbasepoints DESC,
  1;

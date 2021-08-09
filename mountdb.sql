SELECT
  itemid,
  spellid
FROM ((
  SELECT
    CAST(parentitemid AS INT64) AS itemid,
    CAST(spellid AS INT64) AS spellid
  FROM
    itemeffect
  WHERE
    spellcategoryid = "330"
) UNION ALL (
  SELECT
    NULL AS itemid,
    CAST(spell AS INT64) AS spellid
  FROM
    skilllineability
))
JOIN (
  SELECT
    CAST(spellid AS INT64) AS spellid,
    CAST(effectbasepoints AS INT64) AS speed
  FROM
    spelleffect
  WHERE
    effectaura = "32")
USING (spellid)
ORDER BY
  speed DESC,
  itemid,
  spellid;

SELECT
  a.spell_name AS spell_name,
  ARRAY_AGG(
    STRUCT(
      CAST(a.id AS INT64) AS id,
      a.minlevel AS level,
      CAST(b.reagent_0_ AS INT64) AS reagent)
    ORDER BY a.minlevel DESC, CAST(a.id AS INT64)) AS ranks
FROM (
  SELECT DISTINCT
    spellname.id AS id,
    spellname.name_lang AS spell_name,
    CAST(spelllevels.baselevel AS INT64) AS minlevel
  FROM
    spellname,
    spelllevels,
    skilllineability,
    spellpower
  WHERE
    spellname.id = spelllevels.spellid
    AND spellname.id = skilllineability.spell
    AND spellname.id = spellpower.spellid
    AND CAST(spelllevels.baselevel AS INT64) > 0) AS a
LEFT OUTER JOIN
  spellreagents AS b
  ON
    a.id = b.spellid
GROUP BY spell_name
ORDER BY spell_name;

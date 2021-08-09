CREATE OR REPLACE TEMPORARY TABLE tmp_mountdb AS
SELECT
  itemid,
  spellid,
  groundspeed,
  flightspeed
FROM
  ((SELECT
    CAST(parentitemid AS INT64) AS itemid,
    CAST(spellid AS INT64) AS spellid
  FROM
    itemeffect
  WHERE
    spellcategoryid = "330"
  UNION ALL
  SELECT
    NULL AS itemid,
    CAST(spell AS INT64) AS spellid
  FROM
    skilllineability)
  LEFT OUTER JOIN
    (SELECT
      CAST(spellid AS INT64) AS spellid,
      CAST(effectbasepoints AS INT64) AS groundspeed
    FROM
      spelleffect
    WHERE
      effectaura = "32")
  USING (spellid)
  LEFT OUTER JOIN
    (SELECT
      CAST(spellid AS INT64) AS spellid,
      CAST(effectbasepoints AS INT64) AS flightspeed
    FROM
      spelleffect
    WHERE
      effectaura = "207")
  USING (spellid));

-- MountGroundDB
SELECT
  itemid,
  spellid
FROM
  tmp_mountdb
WHERE
  groundspeed IS NOT NULL
ORDER BY
  groundspeed DESC,
  flightspeed DESC NULLS FIRST,
  itemid NULLS FIRST,
  spellid;

-- MountFlightDB
SELECT
  itemid,
  spellid
FROM
  tmp_mountdb
WHERE
  flightspeed IS NOT NULL
ORDER BY
  flightspeed DESC,
  groundspeed DESC NULLS LAST,
  itemid NULLS FIRST,
  spellid;

DROP TABLE IF EXISTS tmp_mountdb;

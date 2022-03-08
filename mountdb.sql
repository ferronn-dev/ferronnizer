CREATE OR REPLACE TEMPORARY TABLE tmp_mountdb AS
WITH mounts AS (
  SELECT
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
    skilllineability
),

ground AS (
  SELECT
    CAST(spellid AS INT64) AS spellid,
    CAST(effectbasepoints AS INT64) AS speed
  FROM
    spelleffect
  WHERE
    effectaura = "32"
),

flight AS (
  SELECT
    CAST(spellid AS INT64) AS spellid,
    CAST(effectbasepoints AS INT64) AS speed
  FROM
    spelleffect
  WHERE
    effectaura = "207"
)

SELECT
  mounts.itemid,
  spellid,
  ground.speed AS groundspeed,
  flight.speed AS flightspeed
FROM
  mounts
LEFT OUTER JOIN ground
  USING (spellid)
LEFT OUTER JOIN flight
  USING (spellid);

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
  itemid ASC NULLS FIRST,
  spellid ASC;

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
  itemid ASC NULLS FIRST,
  spellid ASC;

DROP TABLE IF EXISTS tmp_mountdb;

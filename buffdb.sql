SELECT
    a.name,
    ARRAY_AGG(
        STRUCT(
            CAST(a.id AS INT64) AS id,
            a.minlevel AS level,
            CAST(b.reagent_0_ AS INT64) AS reagent)
        ORDER BY a.minlevel DESC)
FROM (
    SELECT
        n.id id,
        n.name_lang name,
        CAST(l.baselevel AS INT64) minlevel
    FROM
        spellname n,
        spelllevels l,
        skilllineability k
    WHERE
        n.id = l.spellid AND
        n.id = k.spell) a
LEFT OUTER JOIN
    spellreagents b
ON
    a.id = b.spellid
WHERE
    a.minlevel > 0
GROUP BY a.name
ORDER BY a.name;

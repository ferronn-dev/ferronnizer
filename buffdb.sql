SELECT
    a.name,
    ARRAY_AGG(
        STRUCT(
            CAST(a.id AS INT64) AS id,
            a.minlevel AS level,
            CAST(b.reagent_0_ AS INT64) AS reagent)
        ORDER BY a.rank DESC)
FROM (
    SELECT
        s.id id,
        n.name_lang name,
        CAST(SUBSTR(s.namesubtext_lang, 5) AS INT64) rank,
        CAST(l.baselevel AS INT64) minlevel
    FROM
        spell s,
        spellname n,
        spelllevels l,
        skilllineability k
    WHERE
        s.id = n.id AND
        s.id = l.spellid AND
        s.id = k.spell) a
LEFT OUTER JOIN
    spellreagents b
ON
    a.id = b.spellid
WHERE
    a.name IN (
        'Arcane Brilliance',
        'Arcane Intellect',
        'Blessing of Kings',
        'Blessing of Light',
        'Blessing of Might',
        'Blessing of Salvation',
        'Blessing of Wisdom',
        'Dampen Magic',
        'Demon Armor',
        'Demon Skin',
        'Devotion Aura',
        'Divine Spirit',
        'Frost Armor',
        'Gift of the Wild',
        'Greater Blessing of Kings',
        'Greater Blessing of Light',
        'Greater Blessing of Might',
        'Greater Blessing of Salvation',
        'Greater Blessing of Wisdom',
        'Ice Armor',
        'Ice Barrier',
        'Inner Fire',
        'Mage Armor',
        'Mana Shield',
        'Mark of the Wild',
        'Power Word: Fortitude',
        'Prayer of Fortitude',
        'Prayer of Shadow Protection',
        'Prayer of Spirit',
        'Retribution Aura',
        'Righteous Fury',
        'Shadow Protection',
        'Thorns') AND
    a.minlevel > 0
GROUP BY a.name
ORDER BY a.name;

SELECT
  CAST(itemsparse.id AS INT64) AS id,
  CAST(itemsparse.requiredskillrank AS INT64) AS rank
FROM itemsparse, itemeffect, spelleffect
WHERE itemsparse.id = itemeffect.parentitemid
  AND itemeffect.spellcategoryid = '150'
  AND itemeffect.spellid = spelleffect.spellid
  AND spelleffect.effect = '6'
ORDER BY rank DESC, id ASC;

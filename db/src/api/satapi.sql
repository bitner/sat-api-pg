CREATE OR REPLACE VIEW collectionitems AS
  SELECT c.name as collection,
    c.properties as collectionproperties,
    i.id as id,
    i.geometry as geom,
    i.type,
    i.assets,
    data.ST_AsGeoJSON(i.geometry) :: json as geometry,
    i.properties as properties
  FROM data.items i
  RIGHT JOIN
    data.collections c ON i.collection_id = c.collection_id;
ALTER VIEW collectionitems owner to api;

CREATE FUNCTION search(bbox numeric[])
RETURNS setof collectionitems
AS $$
DECLARE
BEGIN
  RETURN QUERY
  SELECT *
  FROM collectionitems 
  WHERE data.ST_INTERSECTS(collectionitems.geom, data.ST_MakeEnvelope(bbox[1], bbox[2], bbox[3], bbox[4], 4326));
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION searchwithfieldsfilter(
  bbox numeric[], include TEXT = NULL, exclude TEXT = NULL)
RETURNS setof collectionitems
AS $$
DECLARE
BEGIN
  IF include IS NOT NULL THEN
    RETURN QUERY
    SELECT collection,
    collectionproperties,
    id,
    geom,
    type,
    assets,
    geometry,
    (select jsonb_object_agg(e.key, e.value)
                from   jsonb_each(properties) e
                where  e.key IN (include)) properties
    FROM collectionitems 
    WHERE data.ST_INTERSECTS(collectionitems.geom, data.ST_MakeEnvelope(bbox[1], bbox[2], bbox[3], bbox[4], 4326));
  ELSIF exclude IS NOT NULL THEN
    RETURN QUERY
    SELECT collection,
    collectionproperties,
    id,
    geom,
    type,
    assets,
    geometry,
    (select jsonb_object_agg(e.key, e.value)
                from   jsonb_each(properties) e
                where  e.key NOT IN (exclude)) properties
    FROM collectionitems 
    WHERE data.ST_INTERSECTS(collectionitems.geom, data.ST_MakeEnvelope(bbox[1], bbox[2], bbox[3], bbox[4], 4326));
  END IF; 
END
$$ LANGUAGE plpgsql;


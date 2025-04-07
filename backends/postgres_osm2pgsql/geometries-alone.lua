-- This is a very simple Lua config for the Flex output
-- which only stores the geometries (not even the tags)
-- for use with Underpass-API to mimics Overpass

local tables = {}

tables.points = osm2pgsql.define_table({
    name = 'points',
    ids = { type = 'node', id_column = 'id' },
    columns = {
        -- { column = 'tags', type = 'jsonb' },
        { column = 'geom', type = 'point', projection = 4326, not_null = true  }
}})

tables.lines = osm2pgsql.define_table({
    name = 'lines',
    ids = { type = 'way', id_column = 'id' },
    columns = {
        -- { column = 'tags', type = 'jsonb' },
        { column = 'geom', type = 'multilinestring', projection = 4326, not_null = true }
}})

tables.polygons = osm2pgsql.define_table({
    name = 'polygons',
    ids = { type = 'area', id_column = 'id' },
    columns = {
        -- { column = 'tags', type = 'jsonb' },
        { column = 'geom', type = 'geometry', projection = 4326, not_null = true },
        -- In this column we'll put the true area calculated on the spheroid
        { column = 'area', type = 'real' }
}})


-- Helper function to remove some of the tags we usually are not interested in.
-- Returns true if there are no tags left.

-- modifié : retourne vrai si aucun tag
local function clean_tags(tags)
    -- tags.odbl = nil
    -- tags.created_by = nil
    -- tags.source = nil
    -- tags['source:ref'] = nil

    return next(tags) == nil
end

-- Helper function that looks at the tags and decides if this is possibly
-- an area.
local function has_area_tags(tags)
    if tags.area == 'yes' or tags.area == 'true' or tags.area == '1' then
        return true
    end
    if tags.area == 'no' or tags.area == 'false' or tags.area == '0'  then
        return false
    end

    return tags.aeroway
        or tags.amenity
        or tags.building
        or tags.harbour
        or tags.historic
        or tags.landuse
        or tags.leisure
        or tags.man_made
        or tags.military
        or tags.natural
        or tags.office
        or tags.place
        or tags.power
        or tags.public_transport
        or tags.shop
        or tags.sport
        or tags.tourism
        or tags.water
        or tags.waterway
        or tags.wetland
        or tags['abandoned:aeroway']
        or tags['abandoned:amenity']
        or tags['abandoned:building']
        or tags['abandoned:landuse']
        or tags['abandoned:power']
        or tags['area:highway']
end

function osm2pgsql.process_node(object)
    if clean_tags(object.tags) then
        return
    end

    local geom = object:as_point()

    tables.points:insert({
        -- tags = object.tags,
        geom = geom -- the point will be automatically be projected to 3857
    })

end

function osm2pgsql.process_way(object)
    if clean_tags(object.tags) then
        return
    end

    -- A closed way that also has the right tags for an area is a polygon.
    if object.is_closed and has_area_tags(object.tags) then
        -- Creating the polygon geometry takes time, so we do it once here
        -- and later store it in the table and use it to calculate the area.
        local geom = object:as_polygon()
        tables.polygons:insert({
            geom = geom,
            area = geom:spherical_area()  -- calculate "real" area in spheroid
        })
    else
        -- modif : on enregistre la géométrie directement en multilinestring
        -- en mergeant les lignes le plus possible
        tables.lines:insert({
            geom = object:as_multilinestring():line_merge()
        })
    end
end

function osm2pgsql.process_relation(object)
    if clean_tags(object.tags) then
        return
    end

    local relation_type = object:grab_tag('type')

    -- Store route relations as multilinestrings
    if relation_type == 'route' or relation_type == 'associatedStreet' or relation_type == 'public_transport' or relation_type == 'waterway' then
        tables.lines:insert({
            geom = object:as_multilinestring():line_merge()
        })
        return
    end

    -- Store multipolygon and boundary relations as polygons
    if relation_type == 'multipolygon' or relation_type == 'boundary' then
        local geom = object:as_multipolygon()
        tables.polygons:insert({
            geom = geom,
            area = geom:spherical_area()
        })
    end
end


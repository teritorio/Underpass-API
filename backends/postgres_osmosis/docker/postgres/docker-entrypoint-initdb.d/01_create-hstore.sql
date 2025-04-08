CREATE EXTENSION IF NOT EXISTS hstore;

-- Same as ->, for code compatibility with json
CREATE OPERATOR ->> (
	LEFTARG = hstore,
	RIGHTARG = text,
	PROCEDURE = fetchval
);

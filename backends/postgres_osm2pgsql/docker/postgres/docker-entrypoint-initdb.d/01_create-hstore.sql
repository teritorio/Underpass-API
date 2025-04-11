CREATE EXTENSION IF NOT EXISTS htsore;

-- Same as ->, for code compatibility with json
CREATE OPERATOR ->> (
	LEFTARG = hstore,
	RIGHTARG = text,
	PROCEDURE = fetchval
);
